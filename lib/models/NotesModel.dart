class NotesModel {
  String userid;
  int seqnbr;
  String topic;
  String description;
  String status;
  String createdat;
  String updatedat;

  NotesModel({
    this.userid,
    this.seqnbr,
    this.topic,
    this.description,
    this.status,
    this.createdat,
    this.updatedat,
  });

  factory NotesModel.fromJson(Map<String, dynamic> json) {
    return NotesModel(
      userid: json['userid'] as String,
      seqnbr: json['seqnbr'] as int,
      topic: json['topic'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdat: json['createdat'] as String,
      updatedat: json['updatedat'] as String,
    );
  }
}

List<NotesModel> notesData = [
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 1,
      topic: "crackwatch",
      description: "get to know whether it is free or not - totally free",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 2,
      topic: "epic games",
      description: "free games every thursday",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 3,
      topic: "fitgirl",
      description: "get everything for free",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 1,
      topic: "crackwatch",
      description: "get to know whether it is free or not",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 2,
      topic: "epic games",
      description: "free games every thursday",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 3,
      topic: "fitgirl",
      description: "get everything for free",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 1,
      topic: "crackwatch",
      description: "get to know whether it is free or not",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 2,
      topic: "epic games",
      description: "free games every thursday",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
  NotesModel(
      userid: "AAA0000001",
      seqnbr: 3,
      topic: "fitgirl",
      description: "get everything for free",
      status: "A",
      createdat: "2021-01-25T12:28:23.807+00:00",
      updatedat: "2021-01-25T12:28:23.807+00:00"),
];
