import 'dart:io';

import 'package:flutter/material.dart';
import 'package:songtube/internal/models/download/download_item.dart';
import 'package:songtube/ui/text_styles.dart';
import 'package:transparent_image/transparent_image.dart';

class DownloadQueueTile extends StatefulWidget {
  const DownloadQueueTile({
    required this.item,
    super.key});
  final DownloadItem item;

  @override
  State<DownloadQueueTile> createState() => _DownloadQueueTileState();
}

class _DownloadQueueTileState extends State<DownloadQueueTile> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight*2,
      child: Padding(
        padding: const EdgeInsets.all(12).copyWith(top: 0),
        child: Row(
          children: [
            _leading(),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6).copyWith(left: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title(),
                    _subtitle(),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StreamBuilder<double?>(
                          stream: widget.item.downloadProgress.stream,
                          builder: (context, snapshot) {
                            final progress = snapshot.data;
                            return Text(progress != null ? (progress*100).round().toString() : '', style: smallTextStyle(context));
                          },
                        ),
                        const SizedBox(width: 4),
                        StreamBuilder<String?>(
                          stream: widget.item.downloadStatus.stream,
                          builder: (context, snapshot) {
                            final status = snapshot.data;
                            return Text(status ?? '', style: smallTextStyle(context));
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Text(
      widget.item.downloadInfo.tags.titleController.text,
      style: smallTextStyle(context).copyWith(fontWeight: FontWeight.bold),
      maxLines: 1,
    );
  }

  Widget _subtitle() {
    return Text(
      widget.item.downloadInfo.tags.artistController.text,
      style: smallTextStyle(context, opacity: 0.6).copyWith(letterSpacing: 0.4, fontWeight: FontWeight.w500),
      maxLines: 1,
    );
  }

  Widget _leading() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0,0),
              color: Theme.of(context).shadowColor.withOpacity(0.1)
            )
          ],
        ), 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FadeInImage(
            fadeInDuration: const Duration(milliseconds: 200),
            image: widget.item.downloadInfo.tags.artwork is String
              ? NetworkImage(widget.item.downloadInfo.tags.artwork)
              : widget.item.downloadInfo.tags.artwork is File
                ? FileImage(widget.item.downloadInfo.tags.artwork) as ImageProvider
                : MemoryImage(widget.item.downloadInfo.tags.artwork),
            placeholder: MemoryImage(kTransparentImage),
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }

  Widget _trailing() {
    return const SizedBox();
  }
}