// To parse this JSON data, do
//
//     final ocrModel = ocrModelFromJson(jsonString);

import 'dart:convert';

OcrModel ocrModelFromJson(Map str) => OcrModel.fromJson(str);

String ocrModelToJson(OcrModel data) => json.encode(data.toJson());

class OcrModel {
  OcrModel({
    this.processingTime,
    this.results,
    this.filename,
    this.version,
    this.cameraId,
    this.timestamp,
  });

  double processingTime;
  List<Result> results;
  String filename;
  int version;
  dynamic cameraId;
  DateTime timestamp;

  factory OcrModel.fromJson(Map<String, dynamic> json) => OcrModel(
        processingTime: json["processing_time"].toDouble(),
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        filename: json["filename"],
        version: json["version"],
        cameraId: json["camera_id"],
        timestamp: DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "processing_time": processingTime,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "filename": filename,
        "version": version,
        "camera_id": cameraId,
        "timestamp": timestamp.toIso8601String(),
      };
}

class Result {
  Result({
    this.box,
    this.plate,
    this.region,
    this.score,
    this.candidates,
    this.dscore,
    this.vehicle,
  });

  Box box;
  String plate;
  Region region;
  double score;
  List<Candidate> candidates;
  double dscore;
  Vehicle vehicle;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        box: Box.fromJson(json["box"]),
        plate: json["plate"],
        region: Region.fromJson(json["region"]),
        score: json["score"].toDouble(),
        candidates: List<Candidate>.from(
            json["candidates"].map((x) => Candidate.fromJson(x))),
        dscore: json["dscore"].toDouble(),
        vehicle: Vehicle.fromJson(json["vehicle"]),
      );

  Map<String, dynamic> toJson() => {
        "box": box.toJson(),
        "plate": plate,
        "region": region.toJson(),
        "score": score,
        "candidates": List<dynamic>.from(candidates.map((x) => x.toJson())),
        "dscore": dscore,
        "vehicle": vehicle.toJson(),
      };
}

class Box {
  Box({
    this.xmin,
    this.ymin,
    this.xmax,
    this.ymax,
  });

  int xmin;
  int ymin;
  int xmax;
  int ymax;

  factory Box.fromJson(Map<String, dynamic> json) => Box(
        xmin: json["xmin"],
        ymin: json["ymin"],
        xmax: json["xmax"],
        ymax: json["ymax"],
      );

  Map<String, dynamic> toJson() => {
        "xmin": xmin,
        "ymin": ymin,
        "xmax": xmax,
        "ymax": ymax,
      };
}

class Candidate {
  Candidate({
    this.score,
    this.plate,
  });

  double score;
  String plate;

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
        score: json["score"].toDouble(),
        plate: json["plate"],
      );

  Map<String, dynamic> toJson() => {
        "score": score,
        "plate": plate,
      };
}

class Region {
  Region({
    this.code,
    this.score,
  });

  String code;
  double score;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        code: json["code"],
        score: json["score"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "score": score,
      };
}

class Vehicle {
  Vehicle({
    this.score,
    this.type,
    this.box,
  });

  double score;
  String type;
  Box box;

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        score: json["score"].toDouble(),
        type: json["type"],
        box: Box.fromJson(json["box"]),
      );

  Map<String, dynamic> toJson() => {
        "score": score,
        "type": type,
        "box": box.toJson(),
      };
}
