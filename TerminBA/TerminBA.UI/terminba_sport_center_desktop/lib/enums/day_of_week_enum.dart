enum DayOfWeek {
  sunday,    // 0
  monday,    // 1
  tuesday,   // 2
  wednesday, // 3
  thursday,  // 4
  friday,    // 5
  saturday,  // 6
}

DayOfWeek dayOfWeekFromJson(int value) => DayOfWeek.values[value];
int dayOfWeekToJson(DayOfWeek day) => day.index;