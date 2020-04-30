import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

getSizes(int radius) async {

  // make request
  Response response =
  await get('https://devapi.randonauts.com/sizes?radius=3000');

  // sample info available in response
  int statusCode = response.statusCode;
  Map<String, String> headers = response.headers;
  String contentType = headers['content-type'];
  String json = response.body;

  return json;
  // TODO convert json to object...

}