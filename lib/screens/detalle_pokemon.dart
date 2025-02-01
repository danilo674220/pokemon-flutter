import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DetallePokemon extends StatelessWidget {
  final String pokemonUrl;

  const DetallePokemon({Key? key, required this.pokemonUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Detalles del Pokémon",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Colors.blue[500]!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchPokemonDetails(pokemonUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (snapshot.hasError) {
            return _buildErrorMessage("Error al cargar los detalles");
          } else if (!snapshot.hasData) {
            return _buildErrorMessage("No hay datos disponibles");
          } else {
            return _buildPokemonDetails(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildPokemonDetails(Map<String, dynamic> pokemonDetails) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPokemonImage(pokemonDetails["sprites"]["front_default"]),
          const SizedBox(height: 20),
          _buildPokemonName(pokemonDetails["name"]),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildDetailCard("Altura", pokemonDetails["height"].toString()),
              _buildDetailCard("Peso", pokemonDetails["weight"].toString()),
              _buildTypes(pokemonDetails["types"]),
              _buildAbilities(pokemonDetails["abilities"]),
            ],
          ),
          const SizedBox(height: 20),
          _buildStats(pokemonDetails["stats"]),
        ],
      ),
    );
  }

Widget _buildPokemonImage(String imageUrl) {
  return Center(
    child: Image.network(
      imageUrl,
      width: 400, 
      height: 400, 
      fit: BoxFit.cover, 
    ),
  );
}

  Widget _buildPokemonName(String name) {
    return Text(
      name.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTypes(List<dynamic> types) {
    return _buildInfoCard("Tipos", types.map<Widget>((type) {
      return Text(
        "- ${type["type"]["name"]}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
    }).toList());
  }

  Widget _buildAbilities(List<dynamic> abilities) {
    return _buildInfoCard("Habilidades", abilities.map<Widget>((ability) {
      return Text(
        "- ${ability["ability"]["name"]}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
    }).toList());
  }

  Widget _buildStats(List<dynamic> stats) {
    return _buildInfoCard("Estadísticas", stats.map<Widget>((stat) {
      return Text(
        "${stat["stat"]["name"]}: ${stat["base_stat"]}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
    }).toList());
  }

  Widget _buildInfoCard(String title, List<Widget> content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...content,
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> fetchPokemonDetails(String url) async {
    final dio = Dio();
    final response = await dio.get(url);
    return response.data;
  }
}