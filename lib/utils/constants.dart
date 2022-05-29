import 'package:bb/models/user_model.dart';
import 'package:flutter/material.dart';

const String APP_NAME = 'BB';
const NOTIFICATION_TOPIC = 'default';
const NOTIFICATION_TOPIC_DEBUG = 'debug';

const String channelId = 'high_importance_channel';

//User Global
UserModel? currentUser;

//Enums
enum Status { pending, publied, disabled}
enum Roles { admin, editor}

//Colors
const Color primaryColor = const Color(0xFF008351);
const Color pointerColor = const Color(0xFF3c3d38);