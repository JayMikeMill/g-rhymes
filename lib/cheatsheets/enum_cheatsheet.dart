// ===========================================
// DART ENUM CHEAT SHEET
// ===========================================

// -------------------
// 1. SIMPLE ENUM
// -------------------
// Enums can be as simple as a list of named constants.
// No extra data or methods. Useful for fixed states or options.
enum SimpleStatus {
  pending,
  active,
  inactive,
  deleted
}

void simpleEnumExample() {
  // Access an enum value
  var s1 = SimpleStatus.active;

  // Print its name
  print(s1.name); // 'active'

  // Print its index (position in the enum, starting from 0)
  print(s1.index); // 1

  // Iterate over all values
  for (var s in SimpleStatus.values) {
    print('Value: $s');
  }

  // Use in switch statement
  switch (s1) {
    case SimpleStatus.pending:
      print('Still waiting...');
      break;
    case SimpleStatus.active:
      print('Everything is good!');
      break;
    case SimpleStatus.inactive:
      print('Not active');
      break;
    case SimpleStatus.deleted:
      print('Removed!');
      break;
  }
}


// -------------------
// 2. ADVANCED ENUM (WITH FIELDS & METHODS)
// -------------------
// Enums can have extra information (fields), constructors, and methods
// This is useful when each enum value needs additional data or behavior.
enum AdvancedStatus {
  pending(1, 'Pending approval'),
  active(2, 'Active status'),
  inactive(3, 'Inactive status'),
  deleted(4, 'Deleted from system');

  // Fields: each enum value can store extra data
  final int code;       // Numeric code associated with status
  final String message; // Human-readable description

  // Constructor: assigns values to the fields
  // Must be const for enums
  const AdvancedStatus(this.code, this.message);

  // Instance methods: can operate on the enum value
  bool isActive() => this == AdvancedStatus.active;
  bool isInactive() => this == AdvancedStatus.inactive;

  // Static helper method: convert numeric code to enum value
  // Static = belongs to the enum itself, not a single value
  static AdvancedStatus fromCode(int code) {
    for (var s in AdvancedStatus.values) {
      if (s.code == code) return s;
    }
    throw Exception('Invalid code: $code');
  }

  // Override toString for nicer printing
  @override
  String toString() => '$name ($code): $message';
}

void advancedEnumExample() {
  var s1 = AdvancedStatus.pending;

  // Access fields
  print(s1.code);    // 1
  print(s1.message); // Pending approval

  // Use methods
  print(s1.isActive());   // false
  print(AdvancedStatus.active.isActive()); // true

  // Iterate over values
  for (var s in AdvancedStatus.values) {
    print('Enum: $s');
  }

  // Switch statement
  switch (s1) {
    case AdvancedStatus.pending:
      print('Waiting...');
      break;
    case AdvancedStatus.active:
      print('All good!');
      break;
    case AdvancedStatus.inactive:
      print('Not active');
      break;
    case AdvancedStatus.deleted:
      print('Removed!');
      break;
  }

  // Convert code to enum
  var s2 = AdvancedStatus.fromCode(3);
  print('From code: $s2'); // inactive (3): Inactive status
}


// -------------------
// 3. ENUM WITH FACTORY-LIKE CONSTRUCTOR LOGIC
// -------------------
// Sometimes you want to create an enum from multiple types of input
// This is usually done with static helper methods because enums themselves
// are fixed, but you can simulate 'factory' behavior using static methods.
enum FactoryStatus {
  pending,
  active,
  inactive,
  deleted;

  // Static method to create enum from string input
  static FactoryStatus fromString(String str) {
    switch (str.toLowerCase()) {
      case 'pending':
        return FactoryStatus.pending;
      case 'active':
        return FactoryStatus.active;
      case 'inactive':
        return FactoryStatus.inactive;
      case 'deleted':
        return FactoryStatus.deleted;
      default:
        throw Exception('Unknown status: $str');
    }
  }

  // Method to check if active
  bool isActive() => this == FactoryStatus.active;
}

void factoryEnumExample() {
  // Create from string
  var s1 = FactoryStatus.fromString('active');

  print(s1);        // active
  print(s1.isActive()); // true
}


// -------------------
// 4. ENUM CHEAT SHEET USAGE TIPS
// -------------------
// - Enums are great for fixed sets of values: states, options, types.
// - Simple enum: lightweight, use when you only need names & index.
// - Advanced enum: use when you need extra data or methods per value.
// - Static methods: simulate factory behavior to create enum from dynamic input.
// - Iteration: use `.values` to loop through all enum values.
// - Switch statements: great for handling all enum cases safely.
// - `name` property: string name of the enum value.
// - `index` property: 0-based position of the value in the enum.
// - `toString()` can be overridden for nicer printing.
