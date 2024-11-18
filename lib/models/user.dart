class User {
  var _uid;
  var _name;
  var _email;
  var _password;
  var _birthDate;
  var _genre; // Género

  // Preferencias alimentarias
  var _ketoDiet = false;
  var _vegetarian = false;
  var _vegan = false;

  var _glutenFree = false;
  var _carnivoreDiet = false;
  var _mediterraneanDiet = false;
  var _noRestrictions = false;

  // Otras preferencias
  var _petsRecipes = false;
  var _kidsRecipes = false;

  User.Empty();

  User(
      this._uid,
      this._name,
      this._email,
      this._password,
      this._birthDate,
      this._genre,
      this._ketoDiet,
      this._vegetarian,
      this._vegan,
      this._glutenFree,
      this._carnivoreDiet,
      this._mediterraneanDiet,
      this._noRestrictions,
      this._petsRecipes,
      this._kidsRecipes,
      );

  // Método para convertir la instancia de User a un Map (para JSON)
  Map<String, dynamic> toJson() => {
    "uid": _uid,
    "name": _name,
    "email": _email,
    "password": _password,
    "birthDate": _birthDate,
    "genre": _genre,
    "ketoDiet": _ketoDiet,
    "vegetarian": _vegetarian,
    "vegan": _vegan,
    "glutenFree": _glutenFree,
    "carnivoreDiet": _carnivoreDiet,
    "mediterraneanDiet": _mediterraneanDiet,
    "noRestrictions": _noRestrictions,
    "petsRecipes": _petsRecipes,
    "kidsRecipes": _kidsRecipes,
  };

  // Constructor para crear una instancia de User a partir de un Map (JSON)
  User.fromJson(Map<String, dynamic> json) {
    _uid = json['uid'];
    _name = json["name"];
    _email = json["email"];
    _password = json["password"];
    _birthDate = json["birthDate"];
    _genre = json["genre"];
    _ketoDiet = json["ketoDiet"];
    _vegetarian = json["vegetarian"];
    _vegan = json["vegan"];
    _glutenFree = json["glutenFree"];
    _carnivoreDiet = json["carnivoreDiet"];
    _mediterraneanDiet = json["mediterraneanDiet"];
    _noRestrictions = json["noRestrictions"];
    _petsRecipes = json["petsRecipes"];
    _kidsRecipes = json["kidsRecipes"];
  }


  get name => _name;

  set name(value) {
    _name = value;
  }

  get email => _email;

  set email(value) {
    _email = value;
  }

  get password => _password;

  set password(value) {
    _password = value;
  }

  get birthDate => _birthDate;

  set birthDate(value) {
    _birthDate = value;
  }

  get genre => _genre;

  set genre(value) {
    _genre = value;
  }

  get ketoDiet => _ketoDiet;

  set ketoDiet(value) {
    _ketoDiet = value;
  }

  get vegetarian => _vegetarian;

  set vegetarian(value) {
    _vegetarian = value;
  }

  get vegan => _vegan;

  set vegan(value) {
    _vegan = value;
  }

  get glutenFree => _glutenFree;

  set glutenFree(value) {
    _glutenFree = value;
  }

  get carnivoreDiet => _carnivoreDiet;

  set carnivoreDiet(value) {
    _carnivoreDiet = value;
  }

  get mediterraneanDiet => _mediterraneanDiet;

  set mediterraneanDiet(value) {
    _mediterraneanDiet = value;
  }

  get noRestrictions => _noRestrictions;

  set noRestrictions(value) {
    _noRestrictions = value;
  }

  get petsRecipes => _petsRecipes;

  set petsRecipes(value) {
    _petsRecipes = value;
  }

  get kidsRecipes => _kidsRecipes;

  set kidsRecipes(value) {
    _kidsRecipes = value;
  }

  get uid => _uid;

  set uid( value){ _uid = value; }

// Getters y setters

}
