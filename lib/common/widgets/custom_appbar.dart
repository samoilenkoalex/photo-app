import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/upload/cubit/photo_taker_cubit.dart';
import '../../features/upload/cubit/uploader_cubit.dart';
import '../../features/upload/cubit/uploader_state.dart';
import '../../theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      actions: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<UploaderCubit, UploaderState>(
                  builder: (context, uploaderState) {
                    return Text(
                      uploaderState.connectionStatus.getStatusText(),
                      style: appBarTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                BlocBuilder<UploaderCubit, UploaderState>(
                  builder: (context, uploaderState) {
                    return Text(
                      '${uploaderState.successfulUploads}/${context.read<PhotoTakerCubit>().state.photos.length} images',
                      style: appBarTextStyle,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
