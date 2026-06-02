enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

DayOfWeek dayOfWeekFromJson(int value) => DayOfWeek.values[value];
int dayOfWeekToJson(DayOfWeek day) => day.index;
