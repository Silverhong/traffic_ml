import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class Singleton {
  Future? InitCameras;

  static final Singleton instance = Singleton.internal();

  factory Singleton() {
    return instance;
  }

  Singleton.internal() {
    print('Instance Singleton Created.');
  }
}
