import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class BelteiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BelteiAppBar({
    super.key,
    this.showSearch = false,
    this.showNotification = false,
    this.actions,
    this.leading,
  });

  final bool showSearch;
  final bool showNotification;
  final List<Widget>? actions;
  final Widget? leading;

  static const _height = 64.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final effectiveActions = actions ??
        [
          if (showSearch)
            IconButton(
              icon: Icon(Icons.search, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          if (showNotification)
            IconButton(
              icon: Icon(Icons.notifications_outlined,
                  color: AppColors.textPrimary),
              onPressed: () {},
            ),
        ];

    return Container(
      color: AppColors.bgPage,
      padding: EdgeInsets.only(top: top),
      height: _height + top,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading case final w?) w,
          const SizedBox(width: 16),
          Image.asset('assets/images/beltei_logo.png',
              height: 48, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Expanded(
            child: Text('BELTEI Portal',
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.primaryNavy),
                overflow: TextOverflow.ellipsis),
          ),
          ...effectiveActions,
        ],
      ),
    );
  }
}
