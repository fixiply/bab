// Internal package
import 'package:bab/models/model.dart';
import 'package:bab/utils/constants.dart';

class MessageModel<T> extends Model {
  String? topic;
  String? send;
  String? response;

  MessageModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    this.topic,
    this.send,
    this.response,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.topic = map['topic'];
    this.send = map['send'];
    this.response = map['response'];
  }

  @override
  Map<String, dynamic> toMap({bool persist = false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'topic': this.topic,
      'send': this.send,
      'response': this.response,
    });
    return map;
  }

  MessageModel copy() {
    return MessageModel(
      uuid: uuid,
      inserted_at: inserted_at,
      updated_at: updated_at,
      creator: creator,
      topic: this.topic,
      send: this.send,
      response: this.response,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is MessageModel && other.uuid == uuid);
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'Message: $topic, UUID: $uuid';
  }
}
