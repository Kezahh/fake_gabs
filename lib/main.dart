import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/beers.csv');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const MyHomePage(title: "Fake GABS here"),
      home: const BeersPage(),
    );
  }
}


class BeersPage extends StatefulWidget {
  const BeersPage({Key? key}) : super(key: key);

  @override
  State<BeersPage> createState() => _BeersPage();
}

class _BeersPage extends State<BeersPage> {

  var _paddle_beers = [];
  var _all_beers = {};
  var _all_beers_string;
  bool _filter_active = false;

  Future<void> _read_in_saved_beers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _all_beers.keys.forEach((k) {
        var beer_row_index = 0;
        _all_beers[k].forEach((v) {
          var beer_index = v["Index"];
          _all_beers[k][beer_row_index]["Saved"] = prefs.getBool("beer${beer_index}") ?? false;
          beer_row_index++;
        });
      });

      _filter_active = prefs.getBool("filter_active") ?? false;
    });
  }

  Future<void> _save_beer(String section_index, int beer_row_index) async {
    final prefs = await SharedPreferences.getInstance();
    var current_beer = _all_beers[section_index][beer_row_index];
    var beer_index = current_beer["Index"];
    await prefs.setBool("beer${beer_index}", current_beer["Saved"]);
  }

  Future<void> _save_filtered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("filter_active", _filter_active);
  }

  int count_saved(String section_index) {
    int count = 0;
    for (int beer_row_index = 0; beer_row_index < _all_beers[section_index].length; beer_row_index++) {
      if (_all_beers[section_index][beer_row_index]["Saved"]) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    print("building beerspage, _all_beers is ${_all_beers.length}");
    var assetBundle = DefaultAssetBundle.of(context);
    //_all_beers_string = assetBundle.loadString("assets/beers.csv").then((beers) { print(beers.split('\n')[0]);});
    if (_all_beers_string == null) {
      _all_beers_string = assetBundle.loadString("assets/beers.csv");
    };
    var section_headers = [];
    //print(_all_beers_string);

    return FutureBuilder<String>(
      future: _all_beers_string,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("woahhhh still loading");
          return Center(child: Text("Loading up some beeeeeeers"));
        } else {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            if (_all_beers.length == 0){
              _all_beers = parse_beers_csv(snapshot.data);
              _read_in_saved_beers();
            };
            
            var viewing_list = [];
            _all_beers.keys.forEach((k) {
              viewing_list.add(_buildSectionHeader(int.parse(k)));
              var beer_count = 0;
              _all_beers[k].forEach((v) {
                if ((_filter_active && v["Saved"]) || !_filter_active) {
                  viewing_list.add(_buildBeerRow(beer_count, k));
                };
                beer_count++;
              });
            });

            return Scaffold(
              appBar: AppBar(
                title: const Text("Beeeeers"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      _filter_active ? Icons.filter_alt : Icons.filter_alt_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _filter_active = !_filter_active;
                        _save_filtered();
                      });
                    },
                  ),
                ],
              ),
              // THIS IS THE GOOD CODE
              //
              // body: ListView.separated(
              //   key: _filter_active ? PageStorageKey("filtered") : PageStorageKey("unfiltered"),
              //   itemCount: viewing_list.length,
              //   //padding: const EdgeInsets.all(16),
              //   separatorBuilder: (BuildContext context, int index) => const Divider(),
              //   itemBuilder: (BuildContext context, int index) {
              //     //return _buildBeerRow(index);
              //     return viewing_list[index];
              //   },
              // ),
              //
              // THIS IS THE TESTING CODE
              body: Column(children: [Expanded(
                child: ListView.separated(
                  key: _filter_active ? PageStorageKey("filtered") : PageStorageKey("unfiltered"),
                  itemCount: _all_beers.length,
                  //shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  itemBuilder: (BuildContext context, int section_index) {
                    //return Text("hello");
                    return Column(
                      children: [
                        Text("parent"),
                        ListView.separated(
                          itemCount: 20,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (BuildContext context, int index) => Divider(),
                          itemBuilder: (BuildContext context, int beer_index) {
                            return Text("Hello Beer ${beer_index}");
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),],),
            );
          };
        };
      },
    );
  }

  Widget _buildBeerRow(int beer_row_index, [String section_index = "1"]) {
    //print("building section ${section_index}, beer number ${beer_row_index}");
    var current_beer = _all_beers[section_index][beer_row_index];
    var beer_index = current_beer["Index"];
    var beer_name = current_beer["Name"];
    var beer_brewery = current_beer["Brewery"];
    var beer_abv = current_beer["Strength"];
    var beer_character = current_beer["Character"];
    var beer_complexity = current_beer["Complexity"];
    var beer_description = current_beer["Description"];
    var beer_saved = current_beer["Saved"];

    // Check if description is contained in inverted commas. If it is, delete them.
    if (beer_description[0] == '"') {
      beer_description = beer_description.substring(1);
    };
    if (beer_description[beer_description.length - 1] == '"') {
      beer_description = beer_description.substring(0, beer_description.length - 1);
    };

    bool testing = true;
    if (testing) {
      return GestureDetector(
        onTap: () {
          setState(() {
            print("${beer_name} was ${current_beer["Saved"]}");
            _all_beers[section_index][beer_row_index]["Saved"] = !current_beer["Saved"];
            _save_beer(section_index, beer_row_index);
            print("${beer_name} is ${current_beer["Saved"]}");
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    beer_index,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget> [
                        Expanded(
                          child: Text(
                            beer_name,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget> [
                        Expanded(child: Text(beer_brewery, style: TextStyle(fontWeight: FontWeight.bold),),),
                      ],
                    ),
                    Row(
                      children: <Widget> [
                        Expanded(
                          child: Row(
                            children: <Widget> [
                              Text("Character: ", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("${beer_character}"),
                              Text("  ABV: ", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("${beer_abv}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget> [
                        Expanded(child: Text(beer_description)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Icon(
                  beer_saved ? Icons.favorite : Icons.favorite_border,
                  color: beer_saved ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListTile(
        title: Text("${beer_index} ${beer_name}"),
        subtitle: Text("${beer_description}"),
        trailing: Icon(
          beer_saved ? Icons.favorite : Icons.favorite_border,
          color: beer_saved ? Colors.red : null,
        ),
        onTap: () {
          setState(() {
            print("${beer_name} was ${current_beer["Saved"]}");
            _all_beers[section_index][beer_row_index]["Saved"] = !current_beer["Saved"];
            _save_beer(section_index, beer_row_index);
            print("${beer_name} is ${current_beer["Saved"]}");
          });
        },
      );
    };
  }

  Widget _buildSectionHeader(int section_index) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 9,
            child: Text(
              "Section ${section_index}",
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("("),
                Text(
                  "${count_saved(section_index.toString())}",
                  style: TextStyle(
                    color: count_saved(section_index.toString()) > 5 ? Colors.red : Colors.black,
                  ),
                ),
                Text("/5)"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Map parse_beers_csv(csv_as_string) {
  var temp_beers_list = [];
  var my_beers_str = csv_as_string;
  if (my_beers_str != null) {
    for (var line in my_beers_str.split("\n")) {
      temp_beers_list.add(line.split("\t"));
    };
    // Remove csv title from list
    var header_row = temp_beers_list[0];
    temp_beers_list.removeAt(0);
    
    for (var row_index = 0; row_index < temp_beers_list.length; row_index++) {
      var beer_row = temp_beers_list[row_index];
      var beer_dict = {};
      for (var heading_index = 0; heading_index < header_row.length; heading_index++) {
        var heading = header_row[heading_index];
        beer_dict[heading] = 0;

        // Problems with blank rows at the end of CSV would cause runtime errors.
        // Check to make sure csv row has all the data.
        if (header_row.length == beer_row.length) {
          if (heading != "" && heading != " ") {
            beer_dict[heading] = beer_row[heading_index];
          };
        };
      };
      beer_dict["Saved"] = false;
      temp_beers_list[row_index] = beer_dict;
    };
  };

  // sort beers into dict with section keys
  var final_beers_list = {};
  for (var row_index = 0; row_index < temp_beers_list.length; row_index++) {
    String beer_section = temp_beers_list[row_index]["Section"];
    if (final_beers_list.containsKey(beer_section)) {
      final_beers_list[beer_section].add(temp_beers_list[row_index]);
    } else {
      final_beers_list[beer_section] = [];
      final_beers_list[beer_section].add(temp_beers_list[row_index]);
    };
  };

  return final_beers_list;
}
