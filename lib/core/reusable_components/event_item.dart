import 'package:evently_c19/core/remote/network/firestore_manager.dart';
import 'package:evently_c19/core/resources/app_constants.dart';
import 'package:evently_c19/core/resources/assets_manager.dart';
import 'package:evently_c19/core/resources/dialog_utils.dart';
import 'package:evently_c19/core/resources/routes_manager.dart';
import 'package:evently_c19/model/event.dart';
import 'package:evently_c19/providers/theme_provider.dart';
import 'package:evently_c19/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventItem extends StatefulWidget {
  Event event;
  bool isFavorite;
  EventItem(this.event, {this.isFavorite = false});

  @override
  State<EventItem> createState() => _EventItemState();
}

class _EventItemState extends State<EventItem> {
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    double screenHeight = MediaQuery.of(context).size.height;
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      height: screenHeight * 0.25,
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.onPrimaryContainer),
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(
            themeProvider.selectedTheme == ThemeMode.dark
                ? AppConstants.darkEventTypeImage[widget.event.type!]!
                : AppConstants.lightEventTypeImage[widget.event.type!]!,
          ),
        ),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            child: Text(
              DateFormat.MMMd().format(widget.event.dateTime!.toDate()),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                decoration: TextDecoration.none,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.event.title ?? "",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (checkFavoriteEvent(userProvider)) {
                      deleteFavoriteEvent(userProvider);
                    } else {
                      addFavoriteEvent(userProvider);
                    }
                  },
                  child: SvgPicture.asset(
                    checkFavoriteEvent(userProvider)
                        ? AssetsManager.heart_selected
                        : AssetsManager.heart,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      RoutesManager.editEventRouteName,
                      arguments: widget.event,
                    );
                  },
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  addFavoriteEvent(UserProvider userProvider) async {
    DialogUtils.showLoadingDialog(context);
    await FirestoreManager.addFavoriteEvent(widget.event);
    setState(() {
      userProvider.user?.favorites?.add(widget.event.id!);
    });
    await FirestoreManager.updateUserFavorites(
        userProvider.user?.favorites ?? []);
    Navigator.of(context).pop();
    DialogUtils.showSnackbar(context, "Event added to your favorite list");
  }

  deleteFavoriteEvent(UserProvider userProvider) async {
    if (!widget.isFavorite) {
      DialogUtils.showLoadingDialog(context);
    }
    if (widget.isFavorite) {
      userProvider.user?.favorites?.remove(widget.event.id!);
    } else {
      setState(() {
        userProvider.user?.favorites?.remove(widget.event.id!);
      });
    }
    await FirestoreManager.deleteFavoriteEvent(widget.event);
    await FirestoreManager.updateUserFavorites(
        userProvider.user?.favorites ?? []);
    if (!widget.isFavorite && mounted) {
      Navigator.of(context).pop();
      DialogUtils.showSnackbar(context, "Event deleted from your favorite list");
    }
  }

  bool checkFavoriteEvent(UserProvider userProvider) {
    return userProvider.user?.favorites?.contains(widget.event.id) ?? false;
  }
}