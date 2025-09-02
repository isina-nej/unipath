import 'package:hive_flutter/hive_flutter.dart';
import '../models/section_model.dart';
import '../services/api_service.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // باکس‌های Hive
  late Box coursesBox;
  late Box sectionsBox;
  late Box lastUpdateBox;

  Future<void> init() async {
    try {
      print('=== شروع راه‌اندازی HiveService ===');

      // اطمینان از باز شدن باکس‌ها
      coursesBox = await Hive.openBox('courses');
      print('باکس درس‌ها: ${coursesBox.name}, تعداد: ${coursesBox.length}');

      sectionsBox = await Hive.openBox('sections');
      print('باکس سکشن‌ها: ${sectionsBox.name}, تعداد: ${sectionsBox.length}');

      lastUpdateBox = await Hive.openBox('lastUpdate');
      print('باکس به‌روزرسانی‌ها آماده شد');

      print('=== راه‌اندازی HiveService با موفقیت انجام شد ===');
    } catch (e) {
      print('خطا در راه‌اندازی HiveService: $e');
      throw e;
    }
  }

  // دریافت همه داده‌ها
  Future<Map<String, dynamic>> getAllData() async {
    try {
      print('\n=== بررسی داده‌های ذخیره شده در Hive ===');

      // Get course_map directly as Map
      final courseMap = coursesBox.get('course_map', defaultValue: {});
      print('داده‌های course_map: $courseMap');

      // Get sections as List of Maps
      final sections = sectionsBox.values.map((section) {
        if (section is SectionModel) {
          return section.toJson();
        }
        return section as Map<String, dynamic>;
      }).toList();
      print('تعداد سکشن‌ها: ${sections.length}');

      final data = {
        'course_map': courseMap,
        'sections': sections,
      };

      print('محتوای نهایی داده‌ها:');
      print('course_map موجود: ${courseMap.isNotEmpty}');
      print('تعداد سکشن‌ها: ${sections.length}');

      return data;
    } catch (e) {
      print('خطا در دریافت داده‌ها از Hive: $e');
      return {};
    }
  }

  // ذخیره داده‌های دریافتی از سرور
  Future<void> saveServerData(Map<String, dynamic> data) async {
    try {
      print('\n=== شروع ذخیره‌سازی داده‌های سرور ===');
      print('ساختار داده‌های دریافتی: ${data.keys.join(', ')}');
      List<Map<String, dynamic>> allSections = [];

      // ذخیره course_map
      if (data.containsKey('course_map')) {
        final courseMap = data['course_map'] as Map<String, dynamic>;
        print('ذخیره‌سازی ${courseMap.length} درس...');
        await coursesBox.clear();
        await coursesBox.put('course_map', courseMap);
        print('✅ نقشه درس‌ها با موفقیت ذخیره شد');
        
        // Extract sections from course_map
        print('استخراج سکشن‌ها از course_map...');
        for (var courseData in courseMap.values) {
          if (courseData is Map && courseData.containsKey('sections')) {
            final courseSections = courseData['sections'] as List?;
            if (courseSections != null) {
              allSections.addAll(courseSections.map((s) => Map<String, dynamic>.from(s)));
            }
          }
        }
        print('یافت شد: ${allSections.length} سکشن در course_map');
      }

      // Save sections
      if (allSections.isNotEmpty) {
        print('شروع ذخیره‌سازی ${allSections.length} سکشن...');
        await sectionsBox.clear();
        var successCount = 0;

        for (var sectionData in allSections) {
          try {
            final id = sectionData['id'] ?? sectionData['section_id'];
            print('پردازش سکشن با شناسه: $id');
            
            if (sectionData['course_id'] == null) {
              print('⚠️ رد شد: سکشن فاقد course_id');
              continue;
            }

            final sectionModel = SectionModel.fromJson(sectionData);
            await sectionsBox.put(sectionModel.id, sectionModel);
            
            if (sectionsBox.containsKey(sectionModel.id)) {
              successCount++;
              print('✅ سکشن $id با موفقیت ذخیره شد');
            }
          } catch (e) {
            print('❌ خطا در ذخیره سکشن: $e');
          }
        }

        print('\n=== نتیجه ذخیره‌سازی سکشن‌ها ===');
        print('✅ موفق: $successCount از ${allSections.length}');
        print('📊 تعداد کل در Hive: ${sectionsBox.length}');
      } else {
        print('⚠️ هیچ سکشنی برای ذخیره یافت نشد');
      }

      await updateLastUpdateTime();
      print('\n✅ ذخیره‌سازی داده‌ها کامل شد');
    } catch (e) {
      print('❌ خطای کلی در saveServerData: $e');
      throw e;
    }
  }

  // بروزرسانی سکشن
  Future<void> updateSection(Map<String, dynamic> section) async {
    final sectionModel = SectionModel.fromJson(section);
    await sectionsBox.put(sectionModel.id, sectionModel);
    print('Section updated in cache. ID: ${sectionModel.id}');
    // بررسی صحت آپدیت
    final updated = sectionsBox.get(sectionModel.id);
    if (updated != null) {
      print('✅ سکشن با موفقیت آپدیت شد: ${updated.toJson()}');
    } else {
      print('❌ خطا در آپدیت سکشن، سکشن پیدا نشد');
    }
  }

  // اضافه کردن سکشن جدید
  Future<void> addSection(Map<String, dynamic> section) async {
    final sectionModel = SectionModel.fromJson(section);
    await sectionsBox.put(sectionModel.id, sectionModel);
  }

  // حذف سکشن
  Future<void> deleteSection(String id) async {
    await sectionsBox.delete(id);
  }

  // بروزرسانی زمان آخرین بروزرسانی
  Future<void> updateLastUpdateTime() async {
    await lastUpdateBox.put('lastUpdate', DateTime.now().toIso8601String());
  }

  // چک کردن نیاز به بروزرسانی
  Future<bool> needsRefresh() async {
    final lastUpdate = lastUpdateBox.get('lastUpdate');
    if (lastUpdate == null) return true;

    final lastUpdateTime = DateTime.parse(lastUpdate);
    final now = DateTime.now();
    return now.difference(lastUpdateTime) > const Duration(hours: 24);
  }

  Future<DateTime?> getLastUpdateTime() async {
    final lastUpdateBox = Hive.box('lastUpdate');
    final timestamp = lastUpdateBox.get('timestamp');
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  // دریافت یک سکشن با شناسه
  Future<Map<String, dynamic>?> getSection(String sectionId) async {
    try {
      print('Getting section with ID: $sectionId');
      // تلاش برای تبدیل ID به int
      int? intId;
      try {
        intId = int.parse(sectionId);
      } catch (e) {
        print('Error parsing section ID to int: $e');
      }

      // اول با String ID تلاش می‌کنیم
      var sectionModel = sectionsBox.get(sectionId);
      // اگر پیدا نشد، با int ID تلاش می‌کنیم
      if (sectionModel == null && intId != null) {
        sectionModel = sectionsBox.get(intId);
      }
      if (sectionModel != null) {
        final result = sectionModel.toJson();
        // Ensure times is always an array
        if (result['times'] == null ||
            (result['times'] is Map && (result['times'] as Map).isEmpty)) {
          result['times'] = [];
        } else if (result['times'] is! List) {
          result['times'] = [result['times']];
        }
        print('Section found (after normalization): $result');
        return result;
      } else {
        print('No section found with ID: $sectionId');
      }
      return null;
    } catch (e) {
      print('Error getting section: $e');
      rethrow;
    }
  }

  // ذخیره یا به‌روزرسانی یک سکشن
  Future<void> saveSection(String sectionId, Map<String, dynamic> data) async {
    try {
      print('Saving section with ID: $sectionId, data: $data');

      // مطمئن میشیم که ID در data با sectionId سازگار هست
      if (data['id'] == null) {
        data['id'] =
            int.tryParse(sectionId) ?? DateTime.now().millisecondsSinceEpoch;
      } else if (data['id'] is String) {
        data['id'] = int.tryParse(data['id'] as String) ??
            int.tryParse(sectionId) ??
            DateTime.now().millisecondsSinceEpoch;
      }

      final sectionModel = SectionModel.fromJson(data);

      // ذخیره با ID عددی
      await sectionsBox.put(sectionModel.id, sectionModel);
      print('Section saved successfully. ID: ${sectionModel.id}');
      // بررسی صحت ذخیره‌سازی
      final saved = sectionsBox.get(sectionModel.id);
      if (saved != null) {
        print('✅ Section with ID ${sectionModel.id} is in Hive. Data: \\n' +
            saved.toJson().toString());
      } else {
        print(
            '❌ Section with ID ${sectionModel.id} NOT found in Hive after save!');
      }
    } catch (e) {
      print('Error saving section: $e');
      rethrow;
    }
  }

  /// ذخیره‌سازی سکشن در سرور و سپس در کش
  Future<void> saveSectionWithSync(
      String sectionId, Map<String, dynamic> data) async {
    try {
      print('Starting synchronized section save...');
      Map<String, dynamic> serverResponse = {};
    
      // Create a clean copy of the data
      var createData = Map<String, dynamic>.from(data);
      // Remove any existing ID to ensure clean creation
      createData.remove('id');

      print('Sending data to server: $createData');
      try {
        // Always use insertSection for new sections
        serverResponse = await ApiService.insertSection(createData);
        print('Server response: $serverResponse');

        if (!serverResponse.containsKey('section_id')) {
          throw Exception('Server did not return a section_id');
        }

        // Update the data with the new section ID from server
        var updatedData = Map<String, dynamic>.from(createData);
        updatedData['id'] = serverResponse['section_id'];

        print('Saving section to local cache with ID: ${updatedData['id']}');
        // Save to local cache with the server-provided ID
        await saveSection(updatedData['id'].toString(), updatedData);

        await updateLastUpdateTime();
        print('Section save completed successfully');
      } catch (e) {
        print('Error in section creation: $e');
        rethrow;
      }
    } on ApiException catch (e) {
      print('API error: ${e.message}');
      if (e.statusCode == 400) {
        throw Exception('Invalid section data: ${e.message}');
      }
      throw Exception('Failed to save section: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Failed to sync section: $e');
    }
  }

  /// به‌روزرسانی سکشن در سرور و سپس در کش
  Future<void> updateSectionWithSync(
      String sectionId, Map<String, dynamic> updatedData) async {
    try {
      print('Starting synchronized section update...');

      // اول در سرور به‌روزرسانی می‌کنیم
      final serverResponse =
          await ApiService.updateSection(int.parse(sectionId), updatedData);

      print('Section updated on server successfully');

      // اطلاعات به‌روز شده را از پاسخ سرور دریافت می‌کنیم
      final finalData = Map<String, dynamic>.from(updatedData);
      if (serverResponse.containsKey('section_id')) {
        finalData['id'] = serverResponse['section_id'].toString();
      }

      // بعد از موفقیت در سرور، در کش به‌روزرسانی می‌کنیم
      await updateSection(finalData);
      print('Section updated in cache successfully');

      await updateLastUpdateTime();
    } on ApiException catch (e) {
      print('API error in synchronized section update: ${e.message}');
      if (e.statusCode == 404) {
        throw Exception('Section not found');
      } else if (e.statusCode == 400) {
        throw Exception('Invalid section data: ${e.message}');
      }
      throw Exception('Failed to update section on server: ${e.message}');
    } catch (e) {
      print('Error in synchronized section update: $e');
      throw Exception('Failed to sync section update: $e');
    }
  }

  /// حذف سکشن از سرور و کش
  Future<void> deleteSectionWithSync(String sectionId) async {
    try {
      print('Starting synchronized section delete...');

      // اول از سرور حذف می‌کنیم
      await ApiService.deleteSection(int.parse(sectionId));
      print('Section deleted from server successfully');

      // بعد از موفقیت در سرور، از کش حذف می‌کنیم
      await deleteSection(sectionId);
      print('Section deleted from cache successfully');

      await updateLastUpdateTime();
    } on ApiException catch (e) {
      print('API error in synchronized section delete: ${e.message}');
      if (e.statusCode == 404) {
        // اگر سکشن در سرور وجود نداشت، فقط از کش حذف می‌کنیم
        await deleteSection(sectionId);
        print('Section not found on server, deleted from cache');
      } else {
        throw Exception('Failed to delete section: ${e.message}');
      }
    } catch (e) {
      print('Error in synchronized section delete: $e');
      throw Exception('Failed to sync section delete: $e');
    }
  }
}
