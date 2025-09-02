import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../../../../data/services/hive_service.dart';
import '../../../../../core/theme/dark_mode_controller.dart';
import '../../../../../core/style/colors.dart';
import '../../../../../shared/widgets/dark_mode_toggle.dart';

class EditCoursePage extends StatefulWidget {
  final String? sectionId;
  final int courseId;
  final String courseName;
  final HiveService hiveService;

  const EditCoursePage({
    Key? key,
    this.sectionId,
    required this.courseId,
    required this.courseName,
    required this.hiveService,
  }) : super(key: key);

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final List<Map<String, String>> sections = [];
  String? selectedDay;
  String? selectedStartTime;
  String? selectedEndTime;
  String? selectedLocation;
  Jalali? selectedExamDate;
  TimeOfDay? selectedExamTime;
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController instructorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  late final DarkModeController darkMode;

  // تعریف FocusNode‌ها برای فیلدهای ورودی
  final FocusNode _capacityFocus = FocusNode();
  final FocusNode _instructorFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();

  bool get _showExamDate {
    final courseName = widget.courseName.trim().toLowerCase();
    return !courseName.startsWith('آز') && !courseName.startsWith('کار');
  }

  String get examDateTime {
    if (selectedExamDate == null || selectedExamTime == null) return '';
    String startTimeStr =
        '${selectedExamTime!.hour.toString().padLeft(2, '0')}:${selectedExamTime!.minute.toString().padLeft(2, '0')}';
    final endTime = TimeOfDay(
        hour: (selectedExamTime!.hour + 2) % 24,
        minute: selectedExamTime!.minute);
    String endTimeStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '${selectedExamDate!.formatFullDate()} ساعت $startTimeStr تا $endTimeStr';
  }

  @override
  void initState() {
    super.initState();
    darkMode = DarkModeController();
    if (widget.sectionId != null) {
      _loadSectionData();
    }
  }

  @override
  void dispose() {
    _capacityFocus.dispose();
    _instructorFocus.dispose();
    _descriptionFocus.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSectionData() async {
    try {
      if (widget.sectionId != null) {
        print('Loading section data for ID: ${widget.sectionId}');
        final localData =
            await widget.hiveService.getSection(widget.sectionId!);
        print('Received local data: $localData');

        if (localData != null && mounted) {
          // Normalize the times data to always be a list
          List<Map<String, dynamic>> normalizedTimes = [];

          // Check both 'times' and 'classes' fields
          var timesData = localData['times'] ?? localData['classes'] ?? [];

          if (timesData is List) {
            normalizedTimes = (timesData.whereType<Map>())
                .map((m) => Map<String, dynamic>.from(m))
                .toList();
          } else if (timesData is Map) {
            normalizedTimes = (timesData.values.whereType<Map>())
                .map((m) => Map<String, dynamic>.from(m))
                .toList();
          }

          print('Normalized times data: $normalizedTimes');

          // Update the data with normalized times
          final normalizedData = {
            ...localData,
            'times': normalizedTimes,
          };

          print('Updating UI with normalized data: $normalizedData');
          _updateUIWithData(normalizedData);
        } else {
          print('No data found or component unmounted');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('اطلاعات سکشن یافت نشد')),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error loading section data: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری اطلاعات: $e')),
        );
      }
    }
  }

  void _updateUIWithData(Map<String, dynamic> data) {
    print('Updating UI with data: $data');
    setState(() {
      sections.clear();

      // لود کردن زمان‌های کلاس
      final times = data['times'] as List<Map<String, dynamic>>? ?? [];

      for (var time in times) {
        final sectionData = {
          'day': (time['day'] ?? '').toString(),
          'startTime': (time['start_time'] ?? '').toString(),
          'endTime': (time['end_time'] ?? '').toString(),
          'location': (time['location'] ?? '').toString(),
        };
        print('Adding time slot: $sectionData');
        sections.add(sectionData);

        // بروزرسانی متغیرهای مربوط به آخرین زمان اضافه شده
        selectedDay = sectionData['day'];
        selectedStartTime = sectionData['startTime'];
        selectedEndTime = sectionData['endTime'];
        locationController.text = sectionData['location']!;
      }

      // لود کردن سایر فیلدها
      capacityController.text = (data['capacity']?.toString() ?? '').trim();
      instructorController.text = (data['instructor_name'] ?? '').trim();
      descriptionController.text = (data['description'] ?? '').trim();

      print('exam_datetime: ${data['exam_datetime']}');
      if (data['exam_datetime'] != null &&
          data['exam_datetime'].toString().isNotEmpty) {
        try {
          final String dateStr = data['exam_datetime'].toString();
          DateTime examDateTime;

          if (dateStr.startsWith('14')) {
            final parts = dateStr.split('T');
            final dateParts = parts[0].split('-');
            final timeParts = parts[1].split(':');

            final jalaliDate = Jalali(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );
            examDateTime = jalaliDate.toDateTime();
            examDateTime = DateTime(
              examDateTime.year,
              examDateTime.month,
              examDateTime.day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1].split('.')[0]),
            );
          } else {
            examDateTime = DateTime.parse(dateStr);
          }

          selectedExamDate = Jalali.fromDateTime(examDateTime);
          selectedExamTime = TimeOfDay(
            hour: examDateTime.hour,
            minute: examDateTime.minute,
          );
          print('Parsed exam date: $selectedExamDate');
          print('Parsed exam time: $selectedExamTime');
        } catch (e) {
          print('Error parsing exam datetime: $e');
        }
      }
    });
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseName,
          style: TextStyle(
            color: darkMode.isDarkMode ? AppColors.darkText : AppColors.white,
          ),
        ),
        actions: [
          DarkModeToggle(controller: darkMode),
        ],
        backgroundColor: darkMode.isDarkMode
            ? AppColors.darkAppBarBackground
            : AppColors.appBarBackground,
      ),
      body: Container(
        color: darkMode.isDarkMode ? AppColors.darkBackground : Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            // اضافه کردن padding پایین برای floating action button
            bottom: 80.0,
          ),
          child: Column(
            children: [
              if (_showExamDate)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تاریخ و ساعت امتحان',
                        style: TextStyle(
                          color: darkMode.isDarkMode
                              ? AppColors.darkText
                              : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: darkMode.isDarkMode
                                ? AppColors.darkDivider
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              examDateTime.isEmpty
                                  ? 'تاریخ و ساعت انتخاب نشده است'
                                  : examDateTime,
                              style: TextStyle(
                                color: darkMode.isDarkMode
                                    ? AppColors.darkTextSecondary
                                    : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkMode.isDarkMode
                                    ? AppColors.darkPrimary
                                    : Colors.blue,
                                foregroundColor: darkMode.isDarkMode
                                    ? AppColors.darkText
                                    : Colors.white,
                              ),
                              onPressed: () async {
                                final Jalali? pickedDate =
                                    await showPersianDatePicker(
                                  context: context,
                                  initialDate: selectedExamDate ?? Jalali.now(),
                                  firstDate: Jalali.now(),
                                  lastDate: Jalali.now().addYears(1),
                                );

                                if (pickedDate != null) {
                                  final TimeOfDay? pickedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: selectedExamTime ??
                                        const TimeOfDay(hour: 9, minute: 0),
                                  );

                                  if (pickedTime != null && mounted) {
                                    setState(() {
                                      selectedExamDate = pickedDate;
                                      selectedExamTime = pickedTime;
                                    });
                                  }
                                }
                              },
                              child: const Text('انتخاب تاریخ و ساعت'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: capacityController,
                focusNode: _capacityFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _fieldFocusChange(
                    context, _capacityFocus, _instructorFocus),
                decoration: InputDecoration(
                  labelText: 'ظرفیت',
                  labelStyle: TextStyle(
                    color: darkMode.isDarkMode
                        ? AppColors.darkText
                        : Colors.black87,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: darkMode.isDarkMode
                          ? AppColors.darkDivider
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                style: TextStyle(
                  color:
                      darkMode.isDarkMode ? AppColors.darkText : Colors.black,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: instructorController,
                focusNode: _instructorFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _fieldFocusChange(
                    context, _instructorFocus, _descriptionFocus),
                decoration: InputDecoration(
                  labelText: 'نام استاد',
                  labelStyle: TextStyle(
                    color: darkMode.isDarkMode
                        ? AppColors.darkText
                        : Colors.black87,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: darkMode.isDarkMode
                          ? AppColors.darkDivider
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                style: TextStyle(
                  color:
                      darkMode.isDarkMode ? AppColors.darkText : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                focusNode: _descriptionFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _fieldFocusChange(
                    context, _descriptionFocus, _locationFocus),
                decoration: InputDecoration(
                  labelText: 'توضیحات',
                  labelStyle: TextStyle(
                    color: darkMode.isDarkMode
                        ? AppColors.darkText
                        : Colors.black87,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: darkMode.isDarkMode
                          ? AppColors.darkDivider
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                style: TextStyle(
                  color:
                      darkMode.isDarkMode ? AppColors.darkText : Colors.black,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedDay,
                      items: ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه']
                          .map((day) =>
                              DropdownMenuItem(value: day, child: Text(day)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDay = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'روز هفته',
                        labelStyle: TextStyle(
                          color: darkMode.isDarkMode
                              ? AppColors.darkText
                              : Colors.black87,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: darkMode.isDarkMode
                                ? AppColors.darkDivider
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: darkMode.isDarkMode
                            ? AppColors.darkText
                            : Colors.black,
                      ),
                      dropdownColor: darkMode.isDarkMode
                          ? AppColors.darkCardBackground
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: darkMode.isDarkMode
                                ? AppColors.darkDivider
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ساعت کلاس',
                                style: TextStyle(
                                  color: darkMode.isDarkMode
                                      ? AppColors.darkText
                                      : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedStartTime != null &&
                                        selectedEndTime != null
                                    ? '$selectedStartTime - $selectedEndTime'
                                    : '',
                                style: TextStyle(
                                  color: darkMode.isDarkMode
                                      ? AppColors.darkText
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.access_time,
                              color: darkMode.isDarkMode
                                  ? AppColors.darkIcon
                                  : Colors.grey.shade700,
                            ),
                            onPressed: () async {
                              final TimeOfDay? startTime = await showTimePicker(
                                context: context,
                                initialTime:
                                    const TimeOfDay(hour: 9, minute: 0),
                                helpText: 'ساعت شروع کلاس را انتخاب کنید',
                              );
                              if (startTime != null && mounted) {
                                final TimeOfDay? endTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: (startTime.hour + 2) % 24,
                                    minute: startTime.minute,
                                  ),
                                  helpText: 'ساعت پایان کلاس را انتخاب کنید',
                                );
                                if (endTime != null && mounted) {
                                  setState(() {
                                    selectedStartTime =
                                        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                                    selectedEndTime =
                                        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                focusNode: _locationFocus,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _locationFocus.unfocus(),
                decoration: InputDecoration(
                  labelText: 'مکان کلاس',
                  labelStyle: TextStyle(
                    color: darkMode.isDarkMode
                        ? AppColors.darkText
                        : Colors.black87,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: darkMode.isDarkMode
                          ? AppColors.darkDivider
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                style: TextStyle(
                  color:
                      darkMode.isDarkMode ? AppColors.darkText : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      darkMode.isDarkMode ? AppColors.darkPrimary : Colors.blue,
                  foregroundColor:
                      darkMode.isDarkMode ? AppColors.darkText : Colors.white,
                ),
                onPressed: () {
                  if (selectedDay == null ||
                      selectedStartTime == null ||
                      selectedEndTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('لطفاً روز و ساعت کلاس را انتخاب کنید')),
                    );
                    return;
                  }

                  final hasConflict = sections.any((section) {
                    return section['day'] == selectedDay &&
                        section['startTime'] == selectedStartTime &&
                        section['endTime'] == selectedEndTime;
                  });

                  if (hasConflict) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('این زمان قبلاً اضافه شده است')),
                    );
                  } else {
                    setState(() {
                      sections.add({
                        'day': selectedDay!,
                        'startTime': selectedStartTime!,
                        'endTime': selectedEndTime!,
                        'location': locationController.text,
                      });
                    });
                  }
                },
                child: const Text('اضافه کردن زمان'),
              ),
              Container(
                height: 200, // ارتفاع ثابت برای لیست زمان‌ها
                child: ListView.builder(
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return Card(
                      color: darkMode.isDarkMode
                          ? AppColors.darkCardBackground
                          : Colors.white,
                      elevation: darkMode.isDarkMode ? 0 : 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          'روز: ${section['day']}',
                          style: TextStyle(
                            color: darkMode.isDarkMode
                                ? AppColors.darkText
                                : Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ساعت: ${section['startTime']} - ${section['endTime']}',
                              style: TextStyle(
                                color: darkMode.isDarkMode
                                    ? AppColors.darkTextSecondary
                                    : Colors.black54,
                              ),
                            ),
                            if (section['location'] != null &&
                                section['location'].toString().isNotEmpty)
                              Text(
                                'مکان: ${section['location']}',
                                style: TextStyle(
                                  color: darkMode.isDarkMode
                                      ? AppColors.darkTextSecondary
                                      : Colors.black54,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: darkMode.isDarkMode
                                ? Colors.redAccent
                                : Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              sections.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: FloatingActionButton.extended(
            onPressed: _saveSection,
            label: const Text('ثبت'),
            backgroundColor:
                darkMode.isDarkMode ? AppColors.darkPrimary : AppColors.blue,
            foregroundColor:
                darkMode.isDarkMode ? AppColors.darkText : Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showSnackBar(String message, {Duration? duration}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: darkMode.isDarkMode ? AppColors.darkText : Colors.white,
          ),
        ),
        backgroundColor:
            darkMode.isDarkMode ? AppColors.darkCardBackground : null,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _saveSection() async {
    print('--- شروع عملیات ذخیره سکشن ---');
    print('مقدار capacityController: ${capacityController.text}');
    print('sections: $sections');
    print('selectedExamDate: $selectedExamDate');
    print('selectedExamTime: $selectedExamTime');
    print('widget.sectionId: ${widget.sectionId}');
    print('widget.courseId: ${widget.courseId}');
    print('widget.courseName: ${widget.courseName}');

    if (capacityController.text.isEmpty || sections.isEmpty) {
      print('خطا: ظرفیت یا زمان کلاس وارد نشده است');
      _showSnackBar('لطفاً ظرفیت و حداقل یک زمان کلاس را وارد کنید');
      return;
    }

    if (_showExamDate && selectedExamDate == null) {
      print('خطا: تاریخ امتحان وارد نشده است');
      _showSnackBar('لطفاً تاریخ امتحان را وارد کنید');
      return;
    }

    _showSnackBar('در حال ذخیره‌سازی...', duration: const Duration(seconds: 1));

    try {
      String? examDateTimeStr;
      if (_showExamDate) {
        if (selectedExamDate != null && selectedExamTime != null) {
          final startDateTime = DateTime(
            selectedExamDate!.year,
            selectedExamDate!.month,
            selectedExamDate!.day,
            selectedExamTime!.hour,
            selectedExamTime!.minute,
          );
          examDateTimeStr = startDateTime.toIso8601String();
        }
      }

      final id =
          widget.sectionId ?? DateTime.now().millisecondsSinceEpoch.toString();
      final sectionData = {
        'id': id,
        'course_id': widget.courseId,
        'capacity': int.tryParse(capacityController.text) ?? 0,
        'instructor_name': instructorController.text.trim(),
        'description': descriptionController.text.trim(),
        'exam_datetime': examDateTimeStr ?? '',
        'times': sections
            .map((section) => {
                  'day': section['day'],
                  'start_time': section['startTime'],
                  'end_time': section['endTime'],
                  'location': (section['location'] ?? '').trim(),
                })
            .toList(),
      };
      print('sectionData نهایی برای ارسال: $sectionData');

      bool success = false;
      const maxRetries = 3;
      int retryCount = 0;
      String? errorMessage;

      while (!success && retryCount < maxRetries) {
        try {
          print('تلاش شماره ${retryCount + 1} برای ذخیره سکشن...');
          if (widget.sectionId != null) {
            print('فراخوانی updateSectionWithSync با id: $id');
            await widget.hiveService.updateSectionWithSync(id, sectionData);
          } else {
            print('فراخوانی saveSectionWithSync با id: $id');
            await widget.hiveService.saveSectionWithSync(id, sectionData);
          }
          print('ذخیره موفقیت‌آمیز بود!');
          success = true;
        } catch (syncError) {
          retryCount++;
          errorMessage = syncError.toString();
          print('Sync error attempt $retryCount: $syncError');
          if (retryCount < maxRetries) {
            print('در حال تلاش مجدد...');
            await Future.delayed(Duration(seconds: 2 * retryCount));
          }
        }
      }

      if (success) {
        print('ثبت نهایی موفقیت‌آمیز بود.');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackBar('اطلاعات با موفقیت ذخیره شد');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(true); // برگرداندن true به عنوان نتیجه
          }
        });
      } else {
        print('ثبت نهایی ناموفق بود. خطا: $errorMessage');
        _showSnackBar(
          'خطا در ذخیره‌سازی: \\n${errorMessage ?? "خطای ناشناخته"}\nلطفاً اتصال اینترنت خود را بررسی کنید و دوباره تلاش کنید.',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('خطای کلی در ذخیره اطلاعات: $e');
      _showSnackBar('خطا در ذخیره اطلاعات: $e');
    }
    print('--- پایان عملیات ذخیره سکشن ---');
  }
}
