Feature: Marvel Characters API Test Suite

  Background:
    * configure ssl = true
    * def baseUrl = 'http://bp-se-test-cabcd9b246a5.herokuapp.com'
    * def username = 'testuser'
    * def apiPath = '/' + username + '/api/characters'
    * def charactersUrl = baseUrl + apiPath

  Scenario: 1. Obtener todos los personajes - Lista inicial (puede estar vacía)
    Given url charactersUrl
    When method get
    Then status 200
    And match response == '#[]'

  Scenario: 2. Crear personaje - Iron Man (exitoso)
    * def timestamp = karate.get('java.lang.System').currentTimeMillis()
    * def uniqueName = 'Iron Man ' + timestamp
    Given url charactersUrl
    And request
      """
      {
        "name": "#(uniqueName)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    And match response.id == '#number'
    And match response.name == uniqueName
    And match response.alterego == 'Tony Stark'
    And match response.description == 'Genius billionaire'
    And match response.powers == ['Armor', 'Flight']
    * def ironManId = response.id

  Scenario: 3. Obtener personaje por ID - Iron Man (exitoso)
    # Primero crear el personaje
    * def timestamp = karate.get('java.lang.System').currentTimeMillis()
    * def uniqueName = 'Iron Man Test3 ' + timestamp
    Given url charactersUrl
    And request
      """
      {
        "name": "#(uniqueName)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    * def createdId = response.id
    
    # Luego obtenerlo por ID
    Given url charactersUrl + '/' + createdId
    When method get
    Then status 200
    And match response.id == createdId
    And match response.name == uniqueName
    And match response.alterego == 'Tony Stark'
    And match response.description == 'Genius billionaire'
    And match response.powers == ['Armor', 'Flight']

  Scenario: 4. Obtener personaje por ID - No existe (404)
    Given url charactersUrl + '/999'
    When method get
    Then status 404
    And match response.error == 'Character not found'

  Scenario: 5. Crear personaje - Nombre duplicado (400)
    # Primero crear Iron Man
    * def timestamp = karate.get('java.lang.System').currentTimeMillis()
    * def uniqueName = 'Iron Man Test5 ' + timestamp
    Given url charactersUrl
    And request
      """
      {
        "name": "#(uniqueName)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    
    # Intentar crear otro con el mismo nombre
    Given url charactersUrl
    And request
      """
      {
        "name": "#(uniqueName)",
        "alterego": "Otro",
        "description": "Otro",
        "powers": ["Armor"]
      }
      """
    When method post
    Then status 400
    And match response.error == 'Character name already exists'

  Scenario: 6. Crear personaje - Campos requeridos faltantes (400)
    Given url charactersUrl
    And request
      """
      {
        "name": "",
        "alterego": "",
        "description": "",
        "powers": []
      }
      """
    When method post
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'
    And match response.powers == 'Powers are required'

  Scenario: 7. Actualizar personaje - Exitoso
    # Primero crear el personaje
    * def timestamp = karate.get('java.lang.System').currentTimeMillis()
    * def uniqueName = 'Iron Man Test7 ' + timestamp
    Given url charactersUrl
    And request
      """
      {
        "name": "#(uniqueName)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    * def createdId = response.id
    
    # Luego actualizarlo
    Given url charactersUrl + '/' + createdId
    And request
      """
      {
        "name": "#(uniqueName)",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    When method put
    Then status 200
    And match response.id == createdId
    And match response.name == uniqueName
    And match response.alterego == 'Tony Stark'
    And match response.description == 'Updated description'
    And match response.powers == ['Armor', 'Flight']

  Scenario: 8. Actualizar personaje - No existe (404)
    Given url charactersUrl + '/999'
    And request
      """
      {
        "name": "Iron Man Test8",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    When method put
    Then status 404
    And match response.error == 'Character not found'

  Scenario: 9. Eliminar personaje - Exitoso
    # Primero crear el personaje
    * def timestamp = karate.get('java.lang.System').currentTimeMillis()
    * def uniqueName = 'Iron Man Test9 ' + timestamp
    Given url charactersUrl
    And request
      """
      {
        "name": "#(uniqueName)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    * def createdId = response.id
    
    # Luego eliminarlo
    Given url charactersUrl + '/' + createdId
    When method delete
    Then status 204

  Scenario: 10. Eliminar personaje - No existe (404)
    Given url charactersUrl + '/999'
    When method delete
    Then status 404
    And match response.error == 'Character not found'

  Scenario: 11. Crear múltiples personajes y verificar lista completa
    # Limpiar datos previos obteniendo la lista actual
    Given url charactersUrl
    When method get
    Then status 200
    * def initialCount = response.length
    
    # Crear Spider-Man
    * def timestamp = karate.get('java.lang.System').currentTimeMillis()
    * def spiderManName = 'Spider-Man Test11 ' + timestamp
    Given url charactersUrl
    And request
      """
      {
        "name": "#(spiderManName)",
        "alterego": "Peter Parker",
        "description": "Superhéroe arácnido",
        "powers": ["Agilidad", "Sentido arácnido", "Trepar muros"]
      }
      """
    When method post
    Then status 201
    * def spiderManId = response.id
    
    # Crear Captain America
    * def captainName = 'Captain America Test11 ' + timestamp
    Given url charactersUrl
    And request
      """
      {
        "name": "#(captainName)",
        "alterego": "Steve Rogers",
        "description": "Súper soldado",
        "powers": ["Fuerza", "Escudo", "Liderazgo"]
      }
      """
    When method post
    Then status 201
    * def captainId = response.id
    
    # Verificar que la lista ahora contiene los personajes creados
    Given url charactersUrl
    When method get
    Then status 200
    * def finalCount = response.length
    * def expectedMinCount = initialCount + 2
    And assert finalCount >= expectedMinCount
    
    # Verificar que Spider-Man está en la lista
    * def spiderMan = response.find(character => character.id == spiderManId)
    And match spiderMan.name == spiderManName
    And match spiderMan.alterego == 'Peter Parker'
    
    # Verificar que Captain America está en la lista
    * def captain = response.find(character => character.id == captainId)
    And match captain.name == captainName
    And match captain.alterego == 'Steve Rogers'
