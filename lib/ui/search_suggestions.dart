import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:songtube/providers/content_provider.dart';
import 'package:songtube/ui/text_styles.dart';

class SearchSuggestions extends StatefulWidget {
  const SearchSuggestions({
    required this.onSearch,
    required this.searchQuery,
    super.key});
  final Function(String) onSearch;
  final String searchQuery;

  @override
  State<SearchSuggestions> createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends State<SearchSuggestions> {

  // Search Client
  http.Client client = http.Client();

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ContentProvider contentProvider = Provider.of(context);
    List<String> searchHistory = contentProvider.getSearchHistory();
    List<String> suggestionsList = [];
    List<String> finalList = [];
    return FutureBuilder(
      future: widget.searchQuery != "" ? client.get(Uri.parse(
        'http://suggestqueries.google.com/complete/search?client=firefox&q=${widget.searchQuery}'),
        headers: {
          'user-agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            '(KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
          'accept-language': 'en-US,en;q=1.0',
        }
      ) : null,
      builder: (context, AsyncSnapshot<http.Response> suggestions) {
        suggestionsList.clear();
        if (suggestions.hasData && widget.searchQuery != "") {
          var map = jsonDecode(suggestions.data!.body);
          var mapList = map[1];
          mapList.forEach((result) {
            suggestionsList.add(result);
          });
        }
        finalList = suggestionsList + searchHistory;
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 0),
            itemExtent: 40,
            itemCount: finalList.length,
            itemBuilder: (context, index) {
              String item = finalList[index];
              return ListTile(
                title: Text(
                  item,
                  style: smallTextStyle(context),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    suggestionsList.contains(item)
                      ? Ionicons.search_outline
                      : Ionicons.hourglass_outline,
                    size: 18,
                    color: Theme.of(context).iconTheme.color
                  ),
                ),
                trailing: !suggestionsList.contains(item) ? IconButton(
                  icon: Icon(Icons.clear, size: 18, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    contentProvider.removeStringfromSearchHistory(index);
                  },
                ) : null,
                onTap: () {
                  contentProvider.addStringtoSearchHistory(item);
                  widget.onSearch(item);
                },
              );
            },
          ),
        );
      },
    );
  }
}