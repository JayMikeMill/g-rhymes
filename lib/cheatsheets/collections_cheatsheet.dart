// =====================
// LISTS (ordered, index-based, like arrays)
// =====================

void listExamples() {
  // Declare a list of strings
  List<String> fruits = ['apple', 'banana', 'cherry'];

  // Access by index
  print(fruits[0]); // 'apple'

  // Add elements
  fruits.add('date');             // add single item at end
  fruits.addAll(['elderberry']);  // add multiple items
  print(fruits);

  // Insert at specific index
  fruits.insert(1, 'blueberry'); // ['apple', 'blueberry', 'banana', 'cherry', 'date', 'elderberry']

  // Remove elements
  fruits.remove('banana');   // remove by value
  fruits.removeAt(0);        // remove by index
  fruits.removeLast();       // remove last element
  fruits.removeWhere((f) => f.startsWith('e')); // remove with condition

  // Iterating
  for (var fruit in fruits) {
    print('Fruit: $fruit');
  }

  // Functional methods
  var upper = fruits.map((f) => f.toUpperCase()).toList(); // transform
  var longOnes = fruits.where((f) => f.length > 5);        // filter
  var firstB = fruits.firstWhere((f) => f.startsWith('b')); // find first match

  // Check
  print(fruits.contains('cherry')); // true
  print(fruits.isEmpty);            // false

  // Sort
  fruits.sort();                    // alphabetical
  fruits.sort((a, b) => a.length.compareTo(b.length)); // custom sort by length
}


// =====================
// MAPS (key → value, like dictionaries / hash maps)
// =====================

void mapExamples() {
  // Declare
  Map<int, String> idToName = {
    1: 'Alice',
    2: 'Bob',
    3: 'Charlie'
  };

  // Access values by key
  print(idToName[1]); // 'Alice'

  // Add or update values
  idToName[4] = 'Diana';        // add new key/value
  idToName[2] = 'Bobby';        // update existing

  // Remove
  idToName.remove(3);           // remove by key

  // Iterate over entries
  idToName.forEach((key, value) {
    print('ID $key -> $value');
  });

  // Iterate like a list of entries
  for (var entry in idToName.entries) {
    print('${entry.key} : ${entry.value}');
  }

  // Keys & values collections
  print(idToName.keys);   // (1, 2, 4)
  print(idToName.values); // (Alice, Bobby, Diana)

  // Check existence
  print(idToName.containsKey(1));   // true
  print(idToName.containsValue('Diana')); // true

  // Transform
  var upperNames = idToName.map((k, v) => MapEntry(k, v.toUpperCase()));
  print(upperNames); // {1: ALICE, 2: BOBBY, 4: DIANA}
}


// =====================
// SETS (unique unordered collection)
// =====================

void setExamples() {
  // Declare
  Set<String> animals = {'dog', 'cat', 'bird'};

  // Add
  animals.add('dog'); // ignored (already exists)
  animals.add('fish');

  // Remove
  animals.remove('cat');

  // Check membership
  print(animals.contains('dog')); // true

  // Iterate
  for (var animal in animals) {
    print('Animal: $animal');
  }

  // Operations (like in math)
  var a = {'dog', 'cat', 'bird'};
  var b = {'dog', 'lion', 'tiger'};

  print(a.union(b));        // {dog, cat, bird, lion, tiger}
  print(a.intersection(b)); // {dog}
  print(a.difference(b));   // {cat, bird}
}


// =====================
// COMMON METHODS (work across all collections)
// =====================

void commonExamples() {
  var nums = [1, 2, 3, 4, 5];

  // Length
  print(nums.length); // 5

  // First/last
  print(nums.first); // 1
  print(nums.last);  // 5

  // Any/all
  print(nums.any((n) => n > 3));  // true (some > 3)
  print(nums.every((n) => n > 0)); // true (all > 0)

  // Fold/reduce (accumulate values)
  var sum = nums.reduce((a, b) => a + b); // 15
  var product = nums.fold(1, (a, b) => a * b); // 120
}


// =====================
// NULL-SAFE ACCESS
// =====================

void nullSafeExamples() {
  Map<int, String> people = {1: 'Alice'};
  print(people[2]); // null (key not found)

  // Provide default
  print(people[2] ?? 'Unknown'); // 'Unknown'

  // Update only if absent
  people.putIfAbsent(2, () => 'Bob');
  print(people);
}


// =====================
// SPREAD & COLLECTION IF/FOR (handy sugar)
// =====================

void spreadExamples() {
  var base = [1, 2, 3];
  var extended = [0, ...base, 4]; // spread operator
  print(extended); // [0, 1, 2, 3, 4]

  var maybe = null;
  var safe = [0, ...?maybe, 4]; // spread only if not null

  // Collection-if
  bool addMore = true;
  var list = [1, 2, if (addMore) 3];
  print(list); // [1, 2, 3]

  // Collection-for
  var doubled = [for (var n in base) n * 2];
  print(doubled); // [2, 4, 6]
}
