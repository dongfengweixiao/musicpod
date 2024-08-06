import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../app/app_model.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/search_input.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../local_audio_model.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';
import 'local_audio_view.dart';

// TODO: move local search to search model and page when
// local audio model methods are migrated to service and only call
// service methods
class LocalAudioSearchPage extends StatelessWidget with WatchItMixin {
  const LocalAudioSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    final titlesResult =
        watchPropertyValue((LocalAudioModel m) => m.localSearchResult?.titles);
    final artistsResult =
        watchPropertyValue((LocalAudioModel m) => m.localSearchResult?.artists);
    final albumsResult =
        watchPropertyValue((LocalAudioModel m) => m.localSearchResult?.albums);
    final genresResult =
        watchPropertyValue((LocalAudioModel m) => m.localSearchResult?.genres);
    final searchQuery =
        watchPropertyValue((LocalAudioModel m) => m.searchQuery);

    final index = watchPropertyValue((AppModel m) => m.localAudioindex);
    final localAudioView = LocalAudioView.values[index];
    final manualFilter = watchPropertyValue((AppModel m) => m.manualFilter);

    void search({required String? text}) {
      if (text != null) {
        model.search(text);
      } else {
        di<LibraryModel>().pop();
      }
    }

    var view = localAudioView;
    if (!manualFilter) {
      if (titlesResult?.isNotEmpty == true &&
          (artistsResult == null || artistsResult.isEmpty) &&
          (albumsResult == null || albumsResult.isEmpty)) {
        view = LocalAudioView.titles;
      } else if (artistsResult?.isNotEmpty == true) {
        view = LocalAudioView.artists;
      } else if (albumsResult?.isNotEmpty == true) {
        view = LocalAudioView.albums;
      } else if (genresResult?.isNotEmpty == true) {
        view = LocalAudioView.genres;
      }
    }

    final nothing = (titlesResult?.isEmpty ?? true) &&
        (albumsResult?.isEmpty ?? true) &&
        (artistsResult?.isEmpty ?? true) &&
        searchQuery?.isNotEmpty == true;

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        titleSpacing: 0,
        actions: [
          Flexible(
            child: Padding(
              padding: appBarSingleActionSpacing,
              child: SearchButton(
                active: true,
                onPressed: () => search(text: null),
              ),
            ),
          ),
        ],
        title: SizedBox(
          width: kSearchBarWidth,
          height: inputHeight - (yaruStyled ? 2 : 0),
          child: SearchInput(
            hintText: '${context.l10n.search}: ${context.l10n.localAudio}',
            text: searchQuery,
            onChanged: (value) {
              search(text: value);
              di<AppModel>().setManualFilter(false);
            },
            onClear: () => search(text: ''),
          ),
        ),
      ),
      body: Column(
        children: [
          LocalAudioControlPanel(
            titlesCount:
                searchQuery?.isNotEmpty == true ? titlesResult?.length : null,
            artistCount:
                searchQuery?.isNotEmpty == true ? artistsResult?.length : null,
            albumCount:
                searchQuery?.isNotEmpty == true ? albumsResult?.length : null,
            genresCounts:
                searchQuery?.isNotEmpty == true ? genresResult?.length : null,
          ),
          Expanded(
            child: LocalAudioBody(
              noResultIcon: nothing
                  ? const AnimatedEmoji(AnimatedEmojis.eyes)
                  : const AnimatedEmoji(AnimatedEmojis.drum),
              noResultMessage: Text(
                nothing ? context.l10n.noLocalSearchFound : context.l10n.search,
              ),
              localAudioView: view,
              titles: titlesResult,
              artists: artistsResult,
              albums: albumsResult,
              genres: genresResult,
            ),
          ),
        ],
      ),
    );
  }
}