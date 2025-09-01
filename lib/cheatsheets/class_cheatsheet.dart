// ===========================================
// DART CLASS CHEAT SHEET: Person Example
// ===========================================

/*
This is a fully annotated Dart class demonstrating:

1. Public and private fields
2. Final and const fields
3. Static fields and methods
4. Getters and setters
5. Constructors (default, named, and factory)
6. Public and private methods
7. Operator overloading
8. toString override
9. Using enums inside classes (optional)
*/

class Person {
  // -------------------
  // 1. FIELDS
  // -------------------
  String firstName;          // Public field (accessible anywhere)
  String lastName;           // Public field
  int _age;                  // Private field (accessible only within this library)
  final DateTime createdAt;  // Final field, must be initialized once
  static int population = 0; // Static field, shared by all instances
  static const String species = 'Homo sapiens'; // Compile-time constant

  // -------------------
  // 2. GETTERS AND SETTERS
  // -------------------
  // Getter for private _age
  int get age => _age;

  // Setter with validation
  set age(int value) {
    if (value >= 0) {
      _age = value;
    } else {
      _age = 0; // Ensure age is never negative
    }
  }

  // -------------------
  // 3. CONSTRUCTORS
  // -------------------

  // Default constructor
  // Initializes firstName, lastName, _age, createdAt
  // Also increments static population count
  Person(this.firstName, this.lastName, int age)
      : _age = age,                     // initialize private field
        createdAt = DateTime.now() {    // initialize final field
    population++;
  }

  // Named constructor
  // Alternative way to create instance
  Person.anonymous()
      : firstName = 'Anonymous',
        lastName = '',
        _age = 0,
        createdAt = DateTime.now() {
    population++;
  }

  // Factory constructor
  // Can process input before returning an instance
  // Useful for parsing or conditional creation
  factory Person.fromString(String info) {
    // Example input: 'Jason Millis,30'
    var parts = info.split(',');
    var nameParts = parts[0].split(' ');
    int age = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    // Return new instance using default constructor
    return Person(
      nameParts[0],
      nameParts.length > 1 ? nameParts[1] : '',
      age,
    );
  }

  // -------------------
  // 4. METHODS
  // -------------------

  // Public method
  // Can be called from anywhere
  void greet() {
    print('Hello, my name is $firstName $lastName and I am $_age years old.');
    _showCreatedAt(); // Call private method
  }

  // Private method (underscore)
  // Only accessible within this class / library
  void _showCreatedAt() {
    print('I was created at $createdAt');
  }

  // Static method
  // Called on the class itself, not an instance
  static void showPopulation() {
    print('Current population: $population');
  }

  // Override toString to provide readable string representation
  @override
  String toString() => '$firstName $lastName ($_age years old)';

  // Operator overloading example
  // '+' operator creates a new Person combining two names and averaging ages
  Person operator +(Person other) {
    return Person(
      '$firstName-${other.firstName}',
      '$lastName-${other.lastName}',
      (_age + other._age) ~/ 2, // average age
    );
  }
}

// -------------------
// 5. MAIN FUNCTION EXAMPLES
// -------------------

void main() {
  // Using default constructor
  var p1 = Person('Jason', 'Millis', 30);

  // Using named constructor
  var p2 = Person.anonymous();

  // Using factory constructor
  var p3 = Person.fromString('Aury Sanchez,25');

  // Access fields and methods
  p1.greet(); // Public method calling private method internally
  print(p2);  // Calls overridden toString
  print(p3);

  // Using setter (with validation)
  p1.age = -5; // Will be set to 0 because of setter logic
  print('p1 age after invalid set: ${p1.age}');

  // Using static method
  Person.showPopulation(); // Access static member from class

  // Operator overloading example
  var p4 = p1 + p3; // Combines names and averages ages
  print('Merged person: $p4');

  // Access static constant
  print('Species: ${Person.species}');
}
