import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/profile/progress_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class ProgressOverviewGraph extends StatelessWidget {
  const ProgressOverviewGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProgressController controller = Get.put(ProgressController());

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor, // 🔹 Clean solid card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cumulative Progress",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Yearly progress overview",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// --- Chart ---
            Obx(() {
              if (controller.isLoading.value) {
                return const SizedBox(
                  height: 250,
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }
              if (!controller.hasOngoingInternship.value) {
                return const SizedBox(
                  height: 250,
                  child: Center(child: Text("No ongoing internship to show progress.")),
                );
              }

              return SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 1,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.25,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 0.7,
                        dashArray: [6, 4],
                      ),
                    ),
                    titlesData: _buildTitles(context, controller),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [_buildLineBarData(controller)],
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(

                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipColor: (_) => AppColors.primary.withOpacity(0.9),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final month = controller.months[spot.x.toInt()];
                            final progressPercent = (spot.y * 100).toStringAsFixed(0);
                            return LineTooltipItem(
                              "$month\n",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: "$progressPercent% Completed",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  FlTitlesData _buildTitles(BuildContext context, ProgressController controller) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            int i = value.toInt();
            if (i >= 0 && i < controller.months.length && i % 2 == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  controller.months[i],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 0.25,
          getTitlesWidget: (value, meta) {
            return Text(
              "${(value * 100).toInt()}%",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineChartBarData _buildLineBarData(ProgressController controller) {
    final spots = <FlSpot>[];
    for (int i = 0; i < controller.months.length; i++) {
      double progress = controller.monthlyCumulativeProgress[controller.months[i]] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), progress));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: AppColors.primary, // 🔹 Single solid line
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3,
          color: AppColors.primary,
          strokeWidth: 1.5,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
