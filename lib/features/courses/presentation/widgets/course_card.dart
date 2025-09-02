// import 'package:flutter/material.dart';
// import '../../../../core/style/colors.dart';
// import '../../../../core/theme/dark_mode_controller.dart';
// import '../../../../shared/widgets/custom_card.dart';

// class CourseCard extends StatelessWidget {
//   final String courseName;
//   final int units;
//   final VoidCallback? onTap;
//   final bool isSelected;

//   const CourseCard({
//     super.key,
//     required this.courseName,
//     required this.units,
//     this.onTap,
//     this.isSelected = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final darkMode = DarkModeController();
//     final isDark = darkMode.isDarkMode;

//     return CustomCard(
//       darkMode: darkMode,
//       onTap: onTap,
//       backgroundColor: isSelected
//           ? (isDark
//               ? AppColors.darkPrimary.withOpacity(0.2)
//               : AppColors.primary.withOpacity(0.1))
//           : null,
//       borderColor: isSelected
//           ? (isDark ? AppColors.darkPrimary : AppColors.primary)
//           : null,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             courseName,
//             style: TextStyle(
//               color: isDark ? AppColors.darkText : AppColors.black87,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '$units واحد',
//             style: TextStyle(
//               color: isDark ? AppColors.darkTextSecondary : AppColors.black54,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
