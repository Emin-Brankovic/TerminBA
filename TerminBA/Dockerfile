#Create a base container
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5078
ENV ASPNETCORE_URLS=http://+:5078

#Create a build container, where we will build the project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
#Publish the project to the app folder in the build container
FROM build AS publish
RUN dotnet publish "TerminBA.WebAPI/TerminBA.WebAPI.csproj" -c Release -o /app

#Create a final container, where we will run the project
FROM base AS final
WORKDIR /app
#Copy the published project in app folder to the final container aka current working directory
COPY --from=publish /app .
#Set the entry point to the main executable of the project 
ENTRYPOINT ["dotnet", "TerminBA.WebAPI.dll"] 