import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'detalle_pokemon.dart';

enum HTTP_STATES { INITIAL, LOADING, ERROR, SUCCESS }

class MiniPokedexPage extends StatefulWidget {
  const MiniPokedexPage({Key? key}) : super(key: key);

  @override
  State<MiniPokedexPage> createState() => _MiniPokedexPageState();
}

class _MiniPokedexPageState extends State<MiniPokedexPage> {
  List<Map<String, dynamic>> pkmns = [];
  HTTP_STATES state = HTTP_STATES.INITIAL;
  int _hoveredIndex = -1; 

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> fetchPokemonData() async {
    final dio = Dio();
    try {
      final response = await dio.get('https://pokeapi.co/api/v2/pokemon');
      List<Map<String, dynamic>> pkmnsTmp = [];
      for (dynamic el in response.data["results"]) {
        pkmnsTmp.add(el);
      }
      await Future.delayed(const Duration(seconds: 3)); 
      setState(() {
        pkmns = pkmnsTmp;
        state = HTTP_STATES.SUCCESS;
      });
    } catch (error) {
      setState(() {
        state = HTTP_STATES.ERROR;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: stateController(state, context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Pokedex",
        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.deepPurple[800],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
    );
  }

  Widget stateController(HTTP_STATES state, BuildContext context) {
    switch (state) {
      case HTTP_STATES.SUCCESS:
        return bodyWithPkmns(context);
      case HTTP_STATES.ERROR:
        return error(context);
      case HTTP_STATES.INITIAL:
      case HTTP_STATES.LOADING:
      default:
        return loading(context);
    }
  }

  Widget loading(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://i.pinimg.com/736x/ee/a0/6e/eea06e724ed72f45033adde64d538224.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡BIENVENIDO!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              Image.asset(
                'assets/images/pokeapi.png',
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading.....',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget error(BuildContext context) {
    return const Center(
      child: Text(
        "¡Vaya! Algo salió mal.",
        style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget bodyWithPkmns(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: pkmns.length,
      itemBuilder: (context, index) {
        final pokemon = pkmns[index];
        List<String> strList = (pokemon["url"] as String).split("/");
        String pkmnId = strList[strList.length - 2];
        return MouseRegion(
          onEnter: (_) => setState(() {
            _hoveredIndex = index;
          }),
          onExit: (_) => setState(() {
            _hoveredIndex = -1; 
          }),
          child: Transform.scale(
            scale: _hoveredIndex == index ? 1.1 : 1.0, 
            child: Card(
              elevation: 5,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetallePokemon(pokemonUrl: pokemon["url"]),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pkmnId.png",
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        pokemon["name"].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "ID: #$pkmnId",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}