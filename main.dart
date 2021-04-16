/* New application: Load recipes into backend and imagestore
Require login to user (admin?) and send header x-auth : token
<directoryPath>
  <user 1>
    user.info
    <recipe 1>
      recipe.json
      image1.jpg
      imgae2.jpg
    <recipe 2>
      recipe.json
      image1.jpg
      image2.jpg
      image3.jpg
    ...
  <user 2>
    user.info
    <recipe 1>
      recipe.json
      image1.jpg
      imgae2.jpg
    <recipe 2>
      recipe.json
      image1.jpg
      image2.jpg
      image3.jpg
    ...
  ...
  
*/

import 'dart:io';
import 'dart:convert' as convert;
import 'package:path/path.dart';

import 'data/recipe.dart';
import 'data/user.dart';
import 'communication/backend.dart';
import 'communication/imagestore.dart';
import 'communication/common.dart';

List getDirectoryContent(Directory directory) {
  List content;
  try {
    content = directory.listSync();
  } catch (exception) {
    print("Directory path don't exist!");
    exit(-1);
  }
  return content;
}

// String fileToJson(File file) {
//   String content = file.readAsStringSync();
//   var jsonContent = convert.jsonEncode(newUser);
//     .then((fileContents) => json.decode(fileContents))
//     .then((jsonData) {
//         // do whatever you want with the data
//     });
// }

Recipe parseRecipe(Directory recipeDirectory) {
  print('');
  String recipeDirName = basename(recipeDirectory.path);
  print('Processing recipe directory ${recipeDirName}');

  List recipeContent = getDirectoryContent(recipeDirectory);

  File recipe;
  List<File> images = [];
  for (var recipeItem in recipeContent) {
    if (recipeItem is File) {
      String name = basename(recipeItem.path);
      print('Recipe file  = $name found!');
      if (name.endsWith('.json')) {
        if (recipe == null) {
          recipe = recipeItem;
        } else {
          // Throw error or exit probram?
          print('ERROR: Recipe file already found!');
        }
      } else {
        images.add(recipeItem);
      }
    } else if (recipeItem is Directory) {
      print('WARNING: Directory  = ${basename(recipeItem.path)} found!');
    }
  }

  print('end processing recipe directory $recipeDirName');
  print('');

  // Recipe jaon file and at least one image are required!
  if (recipe == null || images.length == 0) {
    print('ERROR: Recipe file for recipe directory $recipeDirName missing!');
    exit(-2);
  }
  return Recipe(recipe, images);
}

Future<void> setupRecipe(Recipe recipe, String userToken) async {
  // Create recipe (backend)
  print('Create recipe ...');
  String recipeJson = recipe.recipe.readAsStringSync();
  ResponseReturned response = await createRecipe(recipeJson, userToken);
  if (response.state != ResponseState.successful) {
    exit(-5);
  }

  var responseData =
      convert.jsonDecode(response.response.body) as Map<String, dynamic>;
  print('responseData = $responseData');
  List<dynamic> nameList = responseData['imageFileNames'];
  
  // Upload images to imagestore
  for (int index = 0; index < recipe.images.length; index++) {
    ResponseReturned response =
        await uploadImage(recipe.images[index], nameList[index]);
    if (response.state != ResponseState.successful) {
      exit(-6);
    }
  }
}

User parseUser(Directory userDirectory) {
  print('');
  String userDirName = basename(userDirectory.path);
  print('Processing user directory ${userDirName}');

  List userContent = getDirectoryContent(userDirectory);

  File user;
  List<Recipe> recipeDirectorys = [];
  for (var userItem in userContent) {
    if (userItem is File) {
      print('User file = ${basename(userItem.path)}');
      if (user == null) {
        user = userItem;
      } else {
        print('ERROR: User file already found!');
      }
    } else if (userItem is Directory) {
      print('Recipe directory  = ${basename(userItem.path)}');
      recipeDirectorys.add(parseRecipe(userItem));
    }
  }

  print('end processing user directory $userDirName');
  print('');

  // User json file is required!
  if (user == null) {
    print('ERROR: User file for user directory $userDirName missing!');
    exit(-1);
  }
  return User(user, recipeDirectorys);
}

Future<void> setupUser(User user) async {
  try {
    // Create user
    print('Create user ...');
    String userJson = user.user.readAsStringSync();

    ResponseReturned response = await createUser(userJson);
    if (response.state != ResponseState.successful) {
      exit(-3);
    }

    // Login user
    print('Login user ...');
    String loginJson = user.user.readAsStringSync();

    response = await loginUser(loginJson);
    if (response.state != ResponseState.successful) {
      exit(-4);
    }

    var userToken = response.response.headers['x-auth'];

    for(Recipe recipe in user.recipes) {
      await setupRecipe(recipe, userToken);
    }

    // Logout user
    print('Logout user ...');
    response = await logoutUser(userToken);
    if (response.state != ResponseState.successful) {
      exit(-7);
    }
  } catch (error) {
    print('Error reading user.json file, error = $error');
    exit(-8);
  }
}

void main(List<String> args) async {
  print('Running setup deault user and recipes ...');

  var directoryPath = '../defaultrecipesoriginal';
  // print('arg[0] = ${args[0]}');
  // if (args[0] != null) {
  //   directoryPath = args[0];
  // }
  print('directoryPath = $directoryPath');

  List<User> users = [];

  print('Enter user and recipes file structure parsing ...');
  var directory = Directory(directoryPath);
  List mainContent = getDirectoryContent(directory);
  for (var mainItem in mainContent) {
    if (mainItem is File) {
      print('WARNING: File  = ${basename(mainItem.path)} found!');
    } else if (mainItem is Directory) {
      print('User directory  = ${basename(mainItem.path)} found');
      users.add(parseUser(mainItem));
    }
  }
  print('... end of user and recipes file structure parsing!');

  print('Enter user and recipes setup...');
  for(User user in users) {
    await setupUser(user);
  }
  print('... end of user and recipes setup!');

  print('... end of setup deault user and recipes!');
}

