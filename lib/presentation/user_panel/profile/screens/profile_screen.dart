import 'package:flutter/material.dart';
import 'package:intern_management_app/presentation/user_panel/home/widgets/drawer_widget.dart';
import 'package:intern_management_app/presentation/user_panel/profile/widgets/completed_intership_widget.dart';
import 'package:intern_management_app/presentation/user_panel/profile/widgets/ongoing_intership_widget.dart';
import 'package:intern_management_app/presentation/user_panel/profile/widgets/profile_header_widget.dart';
import 'package:intern_management_app/presentation/user_panel/profile/widgets/progress_widget.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(

              backgroundColor: Color(0xff1E1E1E),
              elevation: 0,
              scrolledUnderElevation: 0,

            ),
            ProfileHeaderWidget(),
            ProgressOverviewGraph(),
            CompletedInternshipsWidget(),
           OngoingInternshipWidget()


          ],

        ),
      ),

    );
  }
}
