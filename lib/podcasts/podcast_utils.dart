import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../common/view/common_widgets.dart';
import '../common/view/icons.dart';
import '../globals.dart';
import '../l10n/l10n.dart';
import '../player/player_model.dart';
import 'podcast_model.dart';
import 'podcast_service.dart';
import 'view/podcast_page.dart';

Future<void> searchAndPushPodcastPage({
  required BuildContext context,
  required String? feedUrl,
  String? itemImageUrl,
  String? genre,
  required bool play,
}) async {
  ScaffoldMessenger.of(context).clearSnackBars();

  if (feedUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.podcastFeedIsEmpty),
      ),
    );
    return;
  }
  final model = di<PodcastModel>();
  final startPlaylist = di<PlayerModel>().startPlaylist;
  final selectedFeedUrl = model.selectedFeedUrl;
  final setSelectedFeedUrl = model.setSelectedFeedUrl;

  setSelectedFeedUrl(feedUrl);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 20),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.loadingPodcastFeed),
          SizedBox(
            height: iconSize,
            width: iconSize,
            child: const Progress(),
          ),
        ],
      ),
    ),
  );

  return findEpisodes(
    feedUrl: feedUrl,
    itemImageUrl: itemImageUrl,
    genre: genre,
  ).then((podcast) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (selectedFeedUrl == feedUrl) {
      return;
    }
    if (podcast.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.podcastFeedIsEmpty),
        ),
      );
      return;
    }

    if (play) {
      startPlaylist.call(listName: feedUrl, audios: podcast).then(
            (_) => setSelectedFeedUrl(null),
          );
    } else {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) {
            return PodcastPage(
              imageUrl: itemImageUrl ?? podcast.firstOrNull?.imageUrl,
              audios: podcast,
              pageId: feedUrl,
              title: podcast.firstOrNull?.album ??
                  podcast.firstOrNull?.title ??
                  feedUrl,
            );
          },
        ),
      ).then((_) {
        setSelectedFeedUrl(null);
      });
    }
  });
}
