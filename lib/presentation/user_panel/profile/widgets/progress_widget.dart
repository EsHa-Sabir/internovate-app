import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/profile/progress_controller.dart';

class ProgressOverviewGraph extends StatelessWidget {
  final ProgressController controller = Get.put(ProgressController());

  @override
  Widget build(BuildContext context) {
    final months = controller.months;

    return Obx(() {
      final monthlyProgress = controller.monthlyProgress;
      final monthlyTotalTasks = controller.monthlyTotalTasks;
      final monthlyDoneTasks = controller.monthlyDoneTasks;

      final spots = <FlSpot>[];
      for (int i = 0; i < months.length; i++) {
        double progress = monthlyProgress[months[i]] ?? 0.0;
        spots.add(FlSpot(i.toDouble(), progress));
      }

      return Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Progress Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            int i = value.toInt();
                            if (i >= 0 && i < months.length) {
                              return Text(
                                months[i],
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              );
                            }
                            return const Text("");
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                    minY: 0,
                    maxY: 1,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (color) => const Color(0xff2E2E2E),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            String month = months[spot.x.toInt()];
                            int total = monthlyTotalTasks[month] ?? 0;
                            int done = monthlyDoneTasks[month] ?? 0;

                            return LineTooltipItem(
                              "$month\n$done / $total tasks completed",
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}