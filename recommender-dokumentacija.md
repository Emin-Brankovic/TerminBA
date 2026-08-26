# Dokumentacija sistema za preporuke

## 1. Uvod

TerminBA sistem za preporuke dizajniran je da korisnicima pruži visoko personalizirane prijedloge objekata i vremenskih termina. Njegova primarna svrha je povećati angažman korisnika i stopu rezervacija predviđanjem vjerovatnoće da će korisnik rezervisati određeni objekat u određenom terminu, na osnovu njegovog historijskog ponašanja, preferencija i ocjena objekata.

## 2. Korištene tehnologije

- **C# / .NET**
- **ML.NET** (`Microsoft.ML`, `Microsoft.ML.FastTree`) za pipeline mašinskog učenja i treniranje modela.
- **Entity Framework Core** za pristup podacima i izvršavanje upita.
- **Newtonsoft.Json** za serijalizaciju objašnjenja preporuka.

## 3. Arhitektura sistema

Sistem je izgrađen kao servis (`RecommendationService`) koji se direktno integriše s bazom podataka aplikacije i modelom mašinskog učenja. Tok podataka sastoji se od sljedećih koraka:

1. **Ekstrakcija podataka:** Preuzimanje historijskih rezervacija i recenzija objekata iz baze podataka.
2. **Inženjering karakteristika:** Ekstrakcija korisničkih profila (`UserProfile`) i preferiranih vremenskih prozora (`UserTimeWindow`) radi izračunavanja relevantnih karakteristika, kao što su razlika u cijeni i ocjena podudaranja vremena.
3. **Treniranje modela:** Korištenje `MLContext` za treniranje binarnog klasifikacijskog modela i spremanje modela kao `.zip` fajla.
4. **Predikcija / inferencija:** Korištenje thread-safe `PredictionEnginePool` komponente za ocjenjivanje budućih dostupnih termina u stvarnom vremenu.
5. **Generisanje objašnjenja:** Kreiranje ljudima razumljivih razloga za preporuke putem `ExplanationBuilder` komponente.

## 4. Izvor i struktura podataka

Primarni izvori podataka su tabele `Reservations`, `FacilityReviews` i `Facilities`. Sistem analizira završene rezervacije kako bi razumio navike korisnika te koristi recenzije kako bi uzeo u obzir zadovoljstvo korisnika.

```csharp
var completedReservations = await _db.Reservations
    .Include(r => r.Facility)
        .ThenInclude(f => f!.AvailableSports)
    .Where(r => r.Status == "CompletedReservationState" || r.Status == "Completed")
    .ToListAsync();

var allReviews = await _db.FacilityReviews.ToListAsync();
```

## 5. Priprema podataka

Za pripremu podataka za treniranje sistem kreira i **pozitivne** i **negativne** uzorke:

- **Pozitivni uzorci:** Generišu se na osnovu stvarnih završenih rezervacija (`Booked = true`).
- **Negativni uzorci:** Generišu se pronalaženjem objekata koje korisnik nikada nije posjetio te kreiranjem hipotetičkih vremenskih termina u istom vremenu kao i stvarne rezervacije (`Booked = false`).

Karakteristike se zatim grade poređenjem korisničkog profila s kandidatom vremenskog termina.

```csharp
// Generating positive sample from actual reservation
var input = FeatureBuilder.Build(profile, candidate, window);
input.Booked = true;
rows.Add(input);

// Generating negative samples from unvisited facilities
foreach (var negFacId in unvisitedFacilityIds)
{
    var negCandidate = new TimeSlotCandidate
    {
        FacilityId = negFacId,
        StartTime = slotStart,
        Price = profile.AveragePaidPrice,
        // ... (other properties)
    };
    var negInput = FeatureBuilder.Build(profile, negCandidate, window);
    negInput.Booked = false;
    rows.Add(negInput);
}
```

## 6. Algoritam preporuka

Pristup preporučivanju formulisan je kao problem **binarne klasifikacije**. Algoritam pokušava predvidjeti hoće li kandidat vremenskog termina biti rezervisan (`1`) ili neće (`0`).

Koristi sljedeće konstruisane karakteristike:

- `SportTypeMatch`: Da li objekat nudi sport koji korisnik najčešće rezerviše?
- `FacilityAvgUserRating`: Prethodna ocjena korisnika za dati objekat.
- `FacilityAvgOverallRating`: Opća ocjena objekta koju su dali svi korisnici.
- `PreviouslyBookedFacility`: Da li je korisnik ranije rezervisao ovaj objekat?
- `PriceDiffFromUserAvg`: Razlika između cijene termina i prosječne cijene koju korisnik plaća.
- `FacilityBookingFrequency`: Koliko često korisnik rezerviše konkretan objekat.
- `TimeWindowFitScore`: Koliko se termin podudara s korisnikovim preferiranim vremenom igranja.

```csharp
public class RecommendationInput
{
    [LoadColumn(0)] public float SportTypeMatch { get; set; }
    [LoadColumn(1)] public float FacilityAvgUserRating { get; set; }
    [LoadColumn(2)] public float FacilityAvgOverallRating { get; set; }
    [LoadColumn(3)] public float PreviouslyBookedFacility { get; set; }
    [LoadColumn(4)] public float PriceDiffFromUserAvg { get; set; }
    [LoadColumn(5)] public float FacilityBookingFrequency { get; set; }
    [LoadColumn(6)] public float TimeWindowFitScore { get; set; }
    
    [LoadColumn(7), ColumnName("Label")] public bool Booked { get; set; }
}
```

## 7. Treniranje modela

Treniranje modela obavlja se pomoću `MLContext` komponente. Podaci se dijele na skup za treniranje i skup za testiranje u omjeru 80/20. Karakteristike se spajaju u jedan vektor, normalizuju Min-Max skaliranjem, a zatim se prosljeđuju **FastTree** treneru za binarnu klasifikaciju, koji se zasniva na gradijentno pojačanim stablima odlučivanja.

Trenirani model se evaluira metrikama kao što su Accuracy i F1 Score, a zatim se sprema na disk.

```csharp
IDataView data = _mlContext.Data.LoadFromEnumerable(trainingRows);
var split = _mlContext.Data.TrainTestSplit(data, testFraction: 0.2, seed: 42);

var pipeline = _mlContext.Transforms
    .Concatenate("Features",
        nameof(RecommendationInput.SportTypeMatch),
        // ... other features
        nameof(RecommendationInput.TimeWindowFitScore))
    .Append(_mlContext.Transforms.NormalizeMinMax("Features"))
    .Append(_mlContext.BinaryClassification.Trainers.FastTree(
        labelColumnName: "Label",
        featureColumnName: "Features",
        numberOfLeaves: 20,
        numberOfTrees: 100,
        minimumExampleCountPerLeaf: 1));

var model = pipeline.Fit(split.TrainSet);
_mlContext.Model.Save(model, data.Schema, ModelPath);
```

## 9. Generisanje preporuka

Kada korisnik zatraži preporuke, sistem najprije određuje njegov preferirani vremenski prozor. Zatim pronalazi sve dostupne, odnosno nezauzete, vremenske termine u svim objektima tokom narednih 14 dana koji odgovaraju korisnikovim preferiranim danima i vremenima.

Ovi kandidati se prosljeđuju `PredictionEnginePool` komponenti radi izračunavanja vjerovatnoće (`Score`) da će korisnik rezervisati termin. Rezultati se zatim sortiraju opadajuće prema rezultatu predikcije.

```csharp
var candidateSlots = await GetCandidateSlotsAsync(window);
var results = new List<RecommendationResult>();

foreach (var slot in candidateSlots)
{
    var input = FeatureBuilder.Build(userProfile, slot, window);
    var prediction = _pool.Predict(modelName: ModelName, example: input);
    var reasons = ExplanationBuilder.Build(input, userProfile, slot, window);

    results.Add(new RecommendationResult
    {
        FacilityId = slot.FacilityId,
        StartTime = slot.StartTime,
        Score = prediction.Probability,
        Reasons = reasons,
        IsPersonalized = true
    });
}

var topResults = results.OrderByDescending(r => r.Score).Take(topN).ToList();
```

## 10. Zaključak

TerminBA sistem za preporuke efikasno kombinuje domensko znanje, kao što su preferirani vremenski prozori i dinamičko određivanje cijena, s mašinskim učenjem putem ML.NET FastTree modela kako bi korisnicima prikazao najrelevantnije objekte i termine.

Dodatno, generisanjem objašnjenja na prirodnom jeziku pomoću `ExplanationBuilder` komponente, sistem osigurava transparentnost i pomaže korisnicima da razumiju zašto im je određeni termin preporučen. Za korisnike bez dovoljno historijskih podataka, odnosno u slučaju problema hladnog početka (*cold start*), pouzdan rezervni mehanizam zasnovan na popularnim i visoko ocijenjenim objektima osigurava neometano korisničko iskustvo.
