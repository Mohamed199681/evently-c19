import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evently_c19/core/remote/network/firestore_manager.dart';
import 'package:evently_c19/core/resources/app_constants.dart';
import 'package:evently_c19/core/resources/dialog_utils.dart';
import 'package:evently_c19/core/reusable_components/custom_btn.dart';
import 'package:evently_c19/core/reusable_components/custom_field.dart';
import 'package:evently_c19/model/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../core/resources/assets_manager.dart';
import '../../../core/resources/my_flutter_app_icons.dart';
import '../widgets/image_tab_view.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int selectedTab = 0;
  DateTime? selectionDate;
  TimeOfDay? selectionTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    descController = TextEditingController(text: widget.event.description);
    selectedTab = AppConstants.eventTypes.indexOf(widget.event.type ?? "sport");
    selectionDate = widget.event.dateTime?.toDate();
    selectionTime = selectionDate != null
        ? TimeOfDay.fromDateTime(selectionDate!)
        : null;
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Event"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.onPrimary,
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            child: SvgPicture.asset(
              AssetsManager.back,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onTertiary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: DefaultTabController(
          length: 5,
          initialIndex: selectedTab < 0 ? 0 : selectedTab,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenHeight * 0.25,
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ImageTabView(imagePath: AssetsManager.sport_light),
                        ImageTabView(imagePath: AssetsManager.birthday_light),
                        ImageTabView(imagePath: AssetsManager.book_light),
                        ImageTabView(imagePath: AssetsManager.exhibition_light),
                        ImageTabView(imagePath: AssetsManager.meeting_light),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  TabBar(
                    onTap: (value) {
                      setState(() {
                        selectedTab = value;
                      });
                    },
                    tabAlignment: TabAlignment.start,
                    dividerHeight: 0,
                    labelColor: Colors.white,
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tabs: [
                      Tab(child: Text("Sport")),
                      Tab(child: Text("Birthday")),
                      Tab(child: Text("Book")),
                      Tab(child: Text("Exhibition")),
                      Tab(child: Text("Meeting")),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text("Title",
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  CustomField(
                    validation: (value) {
                      if (value == null || value.isEmpty) {
                        return "Event title can't be empty";
                      }
                      return null;
                    },
                    controller: titleController,
                    hint: "Event Title",
                    keyboard: TextInputType.text,
                  ),
                  SizedBox(height: 16),
                  Text("Description",
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  CustomField(
                    maxLines: 5,
                    validation: (value) {
                      if (value == null || value.isEmpty) {
                        return "Event description can't be empty";
                      }
                      return null;
                    },
                    controller: descController,
                    hint: "Event Description",
                    keyboard: TextInputType.text,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SvgPicture.asset(AssetsManager.date,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          )),
                      SizedBox(width: 8),
                      Text("Event Date",
                          style: Theme.of(context).textTheme.titleMedium),
                      Spacer(),
                      InkWell(
                        onTap: () => chooseDate(),
                        child: Text(
                          selectionDate != null
                              ? DateFormat.yMMMd().format(selectionDate!)
                              : "Choose Date",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SvgPicture.asset(AssetsManager.time,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          )),
                      SizedBox(width: 8),
                      Text("Event Time",
                          style: Theme.of(context).textTheme.titleMedium),
                      Spacer(),
                      InkWell(
                        onTap: () => chooseTime(),
                        child: Text(
                          selectionTime != null
                              ? selectionTime!.format(context)
                              : "Choose Time",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    child: CustomBtn(
                      title: "Update Event",
                      onClick: () {
                        if (formKey.currentState?.validate() ?? false) {
                          if (selectionDate != null && selectionTime != null) {
                            updateEvent();
                          } else {
                            DialogUtils.showSnackbar(
                                context, "Event date and time are required");
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  chooseDate() async {
    var newDate = await showDatePicker(
      context: context,
      initialDate: selectionDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (newDate != null) {
      setState(() {
        selectionDate = newDate;
      });
    }
  }

  chooseTime() async {
    var newTime = await showTimePicker(
      context: context,
      initialTime: selectionTime ?? TimeOfDay.now(),
    );
    if (newTime != null) {
      setState(() {
        selectionTime = newTime;
      });
    }
  }

  updateEvent() async {
    DateTime eventDate = DateTime(
      selectionDate!.year, selectionDate!.month, selectionDate!.day,
      selectionTime!.hour, selectionTime!.minute,
    );

    // إظهار اللودينغ
    DialogUtils.showLoadingDialog(context);

    // تحديث بيانات كائن الـ widget.event
    widget.event.title = titleController.text;
    widget.event.description = descController.text;
    widget.event.type = AppConstants.eventTypes[selectedTab];
    widget.event.dateTime = Timestamp.fromDate(eventDate);

    try {
      // استدعاء دالة التحديث من الـ FirestoreManager
      await FirestoreManager.updateEvent(widget.event);

      // إخفاء اللودينغ والرجوع للشاشة السابقة أو إرسال رسالة نجاح
      Navigator.of(context).pop(); // إغلاق اللودينغ
      Navigator.of(context).pop(true); // الرجوع للشاشة السابقة مع إرجاع true لتحديث القائمة
      DialogUtils.showSnackbar(context, "Event updated successfully");
    } catch (e) {
      Navigator.of(context).pop(); // إغلاق اللودينغ في حال حدوث خطأ
      DialogUtils.showSnackbar(context, "Failed to update event: $e");
    }
  }
}