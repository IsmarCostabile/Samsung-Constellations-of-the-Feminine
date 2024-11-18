import 'package:flutter/material.dart';
import '../models/node_data.dart';
import 'dart:math';

class CanvasController {
  Size canvasSize = Size.zero;
  double scale = 1.0;
  Offset canvasOffset = Offset.zero;
  Offset? lastFocalPoint;

  void onScaleStart(
      ScaleStartDetails details) {
    lastFocalPoint = details.focalPoint;
  }

  void onScaleUpdate(
      ScaleUpdateDetails details) {
    scale *= details.scale;
    canvasOffset += details.focalPoint -
        lastFocalPoint!;
    lastFocalPoint = details.focalPoint;
  }

  void centerGraph(
      List<(Offset, NodeData)> nodes) {
    if (nodes.isEmpty) return;

    double minX = nodes
        .map((node) => node.$1.dx)
        .reduce(min);
    double maxX = nodes
        .map((node) => node.$1.dx)
        .reduce(max);
    double minY = nodes
        .map((node) => node.$1.dy)
        .reduce(min);
    double maxY = nodes
        .map((node) => node.$1.dy)
        .reduce(max);

    double graphWidth = maxX - minX;
    double graphHeight = maxY - minY;

    Offset graphCenter = Offset(
        minX + graphWidth / 2,
        minY + graphHeight / 2);
    Offset canvasCenter = Offset(
        canvasSize.width / 2,
        canvasSize.height / 2);

    canvasOffset = canvasCenter -
        graphCenter * scale;
    adjustScaleToFitNodes(nodes);
  }

  void adjustScaleToFitNodes(
      List<(Offset, NodeData)> nodes) {
    if (nodes.isEmpty) return;

    double minX = nodes
        .map((node) => node.$1.dx)
        .reduce(min);
    double maxX = nodes
        .map((node) => node.$1.dx)
        .reduce(max);
    double minY = nodes
        .map((node) => node.$1.dy)
        .reduce(min);
    double maxY = nodes
        .map((node) => node.$1.dy)
        .reduce(max);

    double graphWidth = maxX - minX;
    double graphHeight = maxY - minY;

    double scaleX =
        canvasSize.width / graphWidth;
    double scaleY =
        canvasSize.height / graphHeight;

    scale = min(scaleX, scaleY)
        .clamp(0.5, 1.0);
  }
}
