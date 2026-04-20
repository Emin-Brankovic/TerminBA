class DynamicPriceForDateRequest {
	int facilityId;
	DateTime reservationDate;
	String startTime;
	String endTime;

	DynamicPriceForDateRequest(
		this.facilityId,
		this.reservationDate,
		this.startTime,
		this.endTime,
	);

	Map<String, dynamic> toQueryMap() {
		final month = reservationDate.month.toString().padLeft(2, '0');
		final day = reservationDate.day.toString().padLeft(2, '0');

		return {
			'facilityId': facilityId,
			'reservationDate': '${reservationDate.year}-$month-$day',
			'startTime': startTime,
			'endTime': endTime,
		};
	}
}