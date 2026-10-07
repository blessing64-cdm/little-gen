const countingObjects = {
    animals: [
        { emoji: '🐘', name: 'Elephant', sound: 'Trumpet!' },
        { emoji: '🐱', name: 'Cat', sound: 'Meow!' },
        { emoji: '🐶', name: 'Dog', sound: 'Woof!' },
        { emoji: '🦁', name: 'Lion', sound: 'Roar!' },
        { emoji: '🐷', name: 'Pig', sound: 'Oink!' },
        { emoji: '🐸', name: 'Frog', sound: 'Ribbit!' },
        { emoji: '🦓', name: 'Zebra', sound: 'Neigh!' },
        { emoji: '🦒', name: 'Giraffe', sound: 'Mmm!' },
        { emoji: '🐮', name: 'Cow', sound: 'Moo!' },
        { emoji: '🐵', name: 'Monkey', sound: 'Ooh ooh!' }
    ],
    fruits: [
        { emoji: '🍎', name: 'Apple', sound: 'Crunch!' },
        { emoji: '🍌', name: 'Banana', sound: 'Peel!' },
        { emoji: '🍊', name: 'Orange', sound: 'Squeeze!' },
        { emoji: '🍇', name: 'Grapes', sound: 'Pop!' },
        { emoji: '🍉', name: 'Watermelon', sound: 'Splash!' },
        { emoji: '🍓', name: 'Strawberry', sound: 'Sweet!' },
        { emoji: '🍍', name: 'Pineapple', sound: 'Tropical!' },
        { emoji: '🥝', name: 'Kiwi', sound: 'Zip!' },
        { emoji: '🍒', name: 'Cherry', sound: 'Ting!' },
        { emoji: '🥭', name: 'Mango', sound: 'Juicy!' }
    ],
    toys: [
        { emoji: '🚗', name: 'Car', sound: 'Vroom!' },
        { emoji: '🧸', name: 'Teddy Bear', sound: 'Hug!' },
        { emoji: '🎈', name: 'Balloon', sound: 'Pop!' },
        { emoji: '🧩', name: 'Puzzle', sound: 'Click!' },
        { emoji: '🥁', name: 'Drum', sound: 'Bang!' },
        { emoji: '🪁', name: 'Kite', sound: 'Woosh!' },
        { emoji: '🚂', name: 'Train', sound: 'Choo choo!' },
        { emoji: '🛹', name: 'Skateboard', sound: 'Slide!' },
        { emoji: '🚲', name: 'Bicycle', sound: 'Ring ring!' },
        { emoji: '⚽', name: 'Ball', sound: 'Boing!' }
    ],
    school: [
        { emoji: '✏️', name: 'Pencil', sound: 'Scribble!' },
        { emoji: '📚', name: 'Book', sound: 'Flip!' },
        { emoji: '🎨', name: 'Paint', sound: 'Splash!' },
        { emoji: ' Ruler', name: 'Ruler', sound: 'Snap!' },
        { emoji: '🎒', name: 'Backpack', sound: 'Zip!' },
        { emoji: '🔔', name: 'Bell', sound: 'Ding!' },
        { emoji: '🏫', name: 'School', sound: 'Yay!' },
        { emoji: '💡', name: 'Light', sound: 'Ding!' }
    ]
};

const gameData = {
    numbers: [], // Will be populated dynamically based on level
    abc: [
        { id: 'abc_A', value: 'A', name: 'A is for Apple', shortName: 'A', colorClass: 'color-red', objectEmoji: '🍎' },
        { id: 'abc_B', value: 'B', name: 'B is for Bear', shortName: 'B', colorClass: 'color-blue', objectEmoji: '🐻' },
        { id: 'abc_C', value: 'C', name: 'C is for Cat', shortName: 'C', colorClass: 'color-green', objectEmoji: '🐱' },
        { id: 'abc_D', value: 'D', name: 'D is for Dog', shortName: 'D', colorClass: 'color-yellow', objectEmoji: '🐶' },
        { id: 'abc_E', value: 'E', name: 'E is for Elephant', shortName: 'E', colorClass: 'color-red', objectEmoji: '🐘' },
        { id: 'abc_F', value: 'F', name: 'F is for Frog', shortName: 'F', colorClass: 'color-green', objectEmoji: '🐸' },
        { id: 'abc_G', value: 'G', name: 'G is for Giraffe', shortName: 'G', colorClass: 'color-yellow', objectEmoji: '🦒' },
        { id: 'abc_H', value: 'H', name: 'H is for Horse', shortName: 'H', colorClass: 'color-blue', objectEmoji: '🐴' },
        { id: 'abc_I', value: 'I', name: 'I is for Ice Cream', shortName: 'I', colorClass: 'color-red', objectEmoji: '🍦' },
        { id: 'abc_J', value: 'J', name: 'J is for Juice', shortName: 'J', colorClass: 'color-green', objectEmoji: '🧃' },
        { id: 'abc_K', value: 'K', name: 'K is for Kangaroo', shortName: 'K', colorClass: 'color-yellow', objectEmoji: '🦘' },
        { id: 'abc_L', value: 'L', name: 'L is for Lion', shortName: 'L', colorClass: 'color-red', objectEmoji: '🦁' },
        { id: 'abc_M', value: 'M', name: 'M is for Monkey', shortName: 'M', colorClass: 'color-blue', objectEmoji: '🐵' },
        { id: 'abc_N', value: 'N', name: 'N is for Nest', shortName: 'N', colorClass: 'color-yellow', objectEmoji: '🪹' },
        { id: 'abc_O', value: 'O', name: 'O is for Owl', shortName: 'O', colorClass: 'color-blue', objectEmoji: '🦉' },
        { id: 'abc_P', value: 'P', name: 'P is for Pig', shortName: 'P', colorClass: 'color-red', objectEmoji: '🐷' },
        { id: 'abc_Q', value: 'Q', name: 'Q is for Queen', shortName: 'Q', colorClass: 'color-yellow', objectEmoji: '👑' },
        { id: 'abc_R', value: 'R', name: 'R is for Rabbit', shortName: 'R', colorClass: 'color-green', objectEmoji: '🐰' },
        { id: 'abc_S', value: 'S', name: 'S is for Sun', shortName: 'S', colorClass: 'color-blue', objectEmoji: '☀️' },
        { id: 'abc_T', value: 'T', name: 'T is for Tiger', shortName: 'T', colorClass: 'color-red', objectEmoji: '🐯' },
        { id: 'abc_U', value: 'U', name: 'U is for Umbrella', shortName: 'U', colorClass: 'color-green', objectEmoji: '☂️' },
        { id: 'abc_V', value: 'V', name: 'V is for Van', shortName: 'V', colorClass: 'color-blue', objectEmoji: '🚐' },
        { id: 'abc_W', value: 'W', name: 'W is for Watermelon', shortName: 'W', colorClass: 'color-red', objectEmoji: '🍉' },
        { id: 'abc_X', value: 'X', name: 'X is for Xylophone', shortName: 'X', colorClass: 'color-yellow', objectEmoji: '🎹' },
        { id: 'abc_Y', value: 'Y', name: 'Y is for Yo-yo', shortName: 'Y', colorClass: 'color-green', objectEmoji: '🪀' },
        { id: 'abc_Z', value: 'Z', name: 'Z is for Zebra', shortName: 'Z', colorClass: 'color-blue', objectEmoji: '🦓' }
    ],
    colors: [
        { id: 'col_red', value: 'Red', name: 'Red', colorClass: 'color-red' },
        { id: 'col_blue', value: 'Blue', name: 'Blue', colorClass: 'color-blue' },
        { id: 'col_green', value: 'Green', name: 'Green', colorClass: 'color-green' },
        { id: 'col_yellow', value: 'Yellow', name: 'Yellow', colorClass: 'color-yellow' },
        { id: 'col_orange', value: 'Orange', name: 'Orange', colorClass: 'color-orange' },
        { id: 'col_purple', value: 'Purple', name: 'Purple', colorClass: 'color-purple' },
        { id: 'col_pink', value: 'Pink', name: 'Pink', colorClass: 'color-pink' },
        { id: 'col_black', value: 'Black', name: 'Black', colorClass: 'color-black' },
        { id: 'col_white', value: 'White', name: 'White', colorClass: 'color-white' },
        { id: 'col_brown', value: 'Brown', name: 'Brown', colorClass: 'color-brown' }
    ],
    animals: {
        pets: [
            { id: 'ani_dog', name: 'Dog', sound: 'Woof woof!', image: 'assets/animals/dog.png', colorClass: 'color-yellow' },
            { id: 'ani_cat', name: 'Cat', sound: 'Meow!', image: 'assets/animals/cat.png', colorClass: 'color-blue' },
            { id: 'ani_rabbit', name: 'Rabbit', sound: 'Hop hop!', image: 'assets/animals/rabbit.png', colorClass: 'color-white' },
            { id: 'ani_bird', name: 'Bird', sound: 'Tweet tweet!', image: 'assets/animals/bird.png', colorClass: 'color-blue' },
            { id: 'ani_fish', name: 'Fish', sound: 'Blub blub!', image: 'assets/animals/fish.png', colorClass: 'color-orange' }
        ],
        farm: [
            { id: 'ani_goat', name: 'Goat', sound: 'Meeeh!', image: 'assets/animals/goat.png', colorClass: 'color-orange' },
            { id: 'ani_cow', name: 'Cow', sound: 'Moo!', image: 'assets/animals/cow.png', colorClass: 'color-red' },
            { id: 'ani_chicken', name: 'Chicken', sound: 'Cluck cluck!', image: 'assets/animals/chicken.png', colorClass: 'color-yellow' },
            { id: 'ani_pig', name: 'Pig', sound: 'Oink oink!', image: 'assets/animals/pig.png', colorClass: 'color-pink' },
            { id: 'ani_sheep', name: 'Sheep', sound: 'Baa baa!', image: 'assets/animals/sheep.png', colorClass: 'color-white' },
            { id: 'ani_duck', name: 'Duck', sound: 'Quack quack!', image: 'assets/animals/duck.png', colorClass: 'color-blue' },
            { id: 'ani_horse', name: 'Horse', sound: 'Neigh!', image: 'assets/animals/horse.png', colorClass: 'color-brown' }
        ],
        wild: [
            { id: 'ani_elephant', name: 'Elephant', sound: 'Trumpet!', image: 'assets/animals/elephant.png', colorClass: 'color-blue' },
            { id: 'ani_lion', name: 'Lion', sound: 'Roar!', image: 'assets/animals/lion.png', colorClass: 'color-orange' },
            { id: 'ani_tiger', name: 'Tiger', sound: 'Grrr!', image: 'assets/animals/tiger.png', colorClass: 'color-red' },
            { id: 'ani_giraffe', name: 'Giraffe', nameDisplay: 'Giraffe', sound: 'Hummm!', image: 'assets/animals/giraffe.png', colorClass: 'color-yellow' },
            { id: 'ani_zebra', name: 'Zebra', sound: 'Neigh!', image: 'assets/animals/zebra.png', colorClass: 'color-white' },
            { id: 'ani_monkey', name: 'Monkey', sound: 'Ooh ooh!', image: 'assets/animals/monkey.png', colorClass: 'color-brown' },
            { id: 'ani_frog', name: 'Frog', sound: 'Ribbit!', image: 'assets/animals/frog.png', colorClass: 'color-green' }
        ]
    },
    fruits: [
        { id: 'fru_apple', name: 'Apple', sound: 'Apple is a crunchy fruit.', image: 'assets/fruits/apple.png', colorClass: 'color-red' },
        { id: 'fru_banana', name: 'Banana', sound: 'Banana is long and sweet.', image: 'assets/fruits/banana.png', colorClass: 'color-yellow' },
        { id: 'fru_mango', name: 'Mango', sound: 'Mango is soft and tasty!', image: 'assets/fruits/mango.png', colorClass: 'color-orange' },
        { id: 'fru_orange', name: 'Orange', sound: 'Orange is juicy and sweet.', image: 'assets/fruits/orange.png', colorClass: 'color-orange' },
        { id: 'fru_pineapple', name: 'Pineapple', sound: 'Pineapple has a prickly skin!', image: 'assets/fruits/pineapple.png', colorClass: 'color-yellow' },
        { id: 'fru_watermelon', name: 'Watermelon', sound: 'Watermelon is big and refreshing.', image: 'assets/fruits/watermelon.png', colorClass: 'color-green' },
        { id: 'fru_pawpaw', name: 'Pawpaw', sound: 'Pawpaw is a soft African fruit.', image: 'assets/fruits/pawpaw.png', colorClass: 'color-orange' },
        { id: 'fru_guava', name: 'Guava', sound: 'Guava is full of seeds and vitamins.', image: 'assets/fruits/guava.jpg', colorClass: 'color-green' },
        { id: 'fru_coconut', name: 'Coconut', sound: 'Coconut has a hard shell and sweet water.', image: 'assets/fruits/coconut.jpg', colorClass: 'color-white' },
        { id: 'fru_lemon', name: 'Lemon', sound: 'Lemon is very sour and yellow.', image: 'assets/fruits/lemon.jpg', colorClass: 'color-yellow' },
        { id: 'fru_lime', name: 'Lime', sound: 'Lime is small, sour and green.', image: 'assets/fruits/lime.jpeg', colorClass: 'color-green' },
        { id: 'fru_cherry', name: 'Cherry', sound: 'Cherry is small, red and sweet.', image: 'assets/fruits/cherry.jpg', colorClass: 'color-red' },
        { id: 'fru_strawberry', name: 'Strawberry', sound: 'Strawberry has tiny seeds on the outside.', image: 'assets/fruits/strawberry.jpg', colorClass: 'color-red' },
        { id: 'fru_grapes', name: 'Grapes', sound: 'Grapes grow in large bunches.', image: 'assets/fruits/grapes.jpg', colorClass: 'color-purple' },
        { id: 'fru_pear', name: 'Pear', sound: 'Pear is shaped like a bell.', image: 'assets/fruits/pear.jpg', colorClass: 'color-green' },
        { id: 'fru_peach', name: 'Peach', sound: 'Peach is fuzzy and soft.', image: 'assets/fruits/peach.jpg', colorClass: 'color-orange' },
        { id: 'fru_plum', name: 'Plum', sound: 'Plum is dark purple and juicy.', image: 'assets/fruits/plum.jpg', colorClass: 'color-purple' },
        { id: 'fru_avocado', name: 'Avocado', sound: 'Avocado is creamy and healthy.', image: 'assets/fruits/avocado.jpg', colorClass: 'color-green' },
        { id: 'fru_tomato', name: 'Tomato', sound: 'Tomato is a red fruit we eat in salad.', image: 'assets/fruits/tomato.jpg', colorClass: 'color-red' },
        { id: 'fru_garden_egg', name: 'Garden Egg', sound: 'Garden egg is a popular fruit in Nigeria.', image: 'assets/fruits/garden_egg.jpg', colorClass: 'color-green' },
        { id: 'fru_cashew', name: 'Cashew', sound: 'Cashew fruit is juicy with a nut on top.', image: 'assets/fruits/cashew.jpg', colorClass: 'color-yellow' },
        { id: 'fru_date', name: 'Date Fruit', sound: 'Dates are very sweet and sticky.', image: 'assets/fruits/date.jpg', colorClass: 'color-brown' },
        { id: 'fru_tigernut', name: 'Tigernut', sound: 'Tigernut is a small, crunchy African snack.', image: 'assets/fruits/tigernut.jpeg', colorClass: 'color-brown' },
        { id: 'fru_soursop', name: 'Soursop', sound: 'Soursop is prickly and creamy inside.', image: 'assets/fruits/soursop.jpg', colorClass: 'color-green' },
        { id: 'fru_starfruit', name: 'Star Fruit', sound: 'Star fruit looks like a star when sliced.', image: 'assets/fruits/starfruit.jpg', colorClass: 'color-yellow' },
        { id: 'fru_kiwi', name: 'Kiwi', sound: 'Kiwi is fuzzy on the outside and green inside.', image: 'assets/fruits/kiwi.jpg', colorClass: 'color-green' },
        { id: 'fru_blueberry', name: 'Blueberry', sound: 'Blueberries are tiny, round and blue.', image: 'assets/fruits/blueberry.jpg', colorClass: 'color-blue' },
        { id: 'fru_raspberry', name: 'Raspberry', sound: 'Raspberry is red and bumpy.', image: 'assets/fruits/raspberry.jpg', colorClass: 'color-red' },
        { id: 'fru_blackberry', name: 'Blackberry', sound: 'Blackberry is dark and sweet.', image: 'assets/fruits/blackberry.jpg', colorClass: 'color-purple' },
        { id: 'fru_fig', name: 'Fig', sound: 'Fig is a sweet fruit with many tiny seeds.', image: 'assets/fruits/fig.jpg', colorClass: 'color-purple' }
    ],
    vegetables: [
        { id: 'veg_carrot', name: 'Carrot', sound: 'Carrot is used for cooking.', image: 'assets/vegetables/carrot.jpg', colorClass: 'color-orange' },
        { id: 'veg_cabbage', name: 'Cabbage', sound: 'Cabbage is great in salads.', image: 'assets/vegetables/cabbage.jpg', colorClass: 'color-green' },
        { id: 'veg_lettuce', name: 'Lettuce', sound: 'Lettuce is a crunchy green leaf.', image: 'assets/vegetables/lettuce.jpg', colorClass: 'color-green' },
        { id: 'veg_spinach', name: 'Spinach', sound: 'Spinach is a healthy green vegetable.', image: 'assets/vegetables/spinach.jpg', colorClass: 'color-green' },
        { id: 'veg_broccoli', name: 'Broccoli', sound: 'Broccoli looks like a tiny tree.', image: 'assets/vegetables/broccoli.jpg', colorClass: 'color-green' },
        { id: 'veg_cauliflower', name: 'Cauliflower', sound: 'Cauliflower is white and healthy.', image: 'assets/vegetables/cauliflower.png', colorClass: 'color-white' },
        { id: 'veg_cucumber', name: 'Cucumber', sound: 'Cucumber is cool and crunchy.', image: 'assets/vegetables/cucumber.jpg', colorClass: 'color-green' },
        { id: 'veg_tomato', name: 'Tomato', sound: 'Tomato is a red vegetable we eat.', image: 'assets/vegetables/tomato.jpg', colorClass: 'color-red' },
        { id: 'veg_onion', name: 'Onion', sound: 'Onion makes food smell good.', image: 'assets/vegetables/onion.jpg', colorClass: 'color-white' },
        { id: 'veg_garlic', name: 'Garlic', sound: 'Garlic is very healthy.', image: 'assets/vegetables/garlic.jpg', colorClass: 'color-white' },
        { id: 'veg_pepper', name: 'Pepper', sound: 'Pepper makes food spicy!', image: 'assets/vegetables/pepper.png', colorClass: 'color-red' },
        { id: 'veg_green_pepper', name: 'Green Pepper', sound: 'Green pepper is crunchy and sweet.', image: 'assets/vegetables/green_pepper.png', colorClass: 'color-green' },
        { id: 'veg_red_pepper', name: 'Red Pepper', sound: 'Red pepper is bright and tasty.', image: 'assets/vegetables/red_pepper.png', colorClass: 'color-red' },
        { id: 'veg_yellow_pepper', name: 'Yellow Pepper', sound: 'Yellow pepper is very colorful.', image: 'assets/vegetables/yellow_pepper.png', colorClass: 'color-yellow' },
        { id: 'veg_corn', name: 'Sweet Corn', sound: 'Sweet corn is yellow and tasty.', image: 'assets/vegetables/corn.jpg', colorClass: 'color-yellow' },
        { id: 'veg_green_beans', name: 'Green Beans', sound: 'Green beans are long and crunchy.', image: 'assets/vegetables/green_beans.jpg', colorClass: 'color-green' },
        { id: 'veg_peas', name: 'Peas', sound: 'Peas are small green balls.', image: 'assets/vegetables/peas.jpg', colorClass: 'color-green' }
    ],
    shapes: [
        { id: 'shape_circle', value: '🟡', name: 'Circle', colorClass: 'color-yellow' },
        { id: 'shape_square', value: '🟥', name: 'Square', colorClass: 'color-red' },
        { id: 'shape_triangle', value: '🔺', name: 'Triangle', colorClass: 'color-orange' },
        { id: 'shape_star', value: '⭐', name: 'Star', colorClass: 'color-yellow' },
        { id: 'shape_heart', value: '❤️', name: 'Heart', colorClass: 'color-pink' },
        { id: 'shape_diamond', value: '🔷', name: 'Diamond', colorClass: 'color-blue' }
    ],
    phonics: [
        { id: 'ph_a', value: 'A', name: 'Ah!', objectEmoji: '🍎', colorClass: 'color-red' },
        { id: 'ph_b', value: 'B', name: 'Buh!', objectEmoji: '🐻', colorClass: 'color-blue' },
        { id: 'ph_c', value: 'C', name: 'Cuh!', objectEmoji: '🐱', colorClass: 'color-green' },
        { id: 'ph_d', value: 'D', name: 'Duh!', objectEmoji: '🐶', colorClass: 'color-yellow' },
        { id: 'ph_e', value: 'E', name: 'Eh!', objectEmoji: '🐘', colorClass: 'color-orange' },
        { id: 'ph_f', value: 'F', name: 'Fff!', objectEmoji: '🐸', colorClass: 'color-purple' },
        { id: 'ph_g', value: 'G', name: 'Guh!', objectEmoji: '🦒', colorClass: 'color-yellow' },
        { id: 'ph_h', value: 'H', name: 'Huh!', objectEmoji: '🐴', colorClass: 'color-brown' },
        { id: 'ph_i', value: 'I', name: 'Ih!', objectEmoji: '🍦', colorClass: 'color-red' },
        { id: 'ph_j', value: 'J', name: 'Juh!', objectEmoji: '🧃', colorClass: 'color-green' },
        { id: 'ph_k', value: 'K', name: 'Kuh!', objectEmoji: '🦘', colorClass: 'color-yellow' },
        { id: 'ph_l', value: 'L', name: 'Lll!', objectEmoji: '🦁', colorClass: 'color-orange' },
        { id: 'ph_m', value: 'M', name: 'Mmm!', objectEmoji: '🐵', colorClass: 'color-brown' },
        { id: 'ph_n', value: 'N', name: 'Nnn!', objectEmoji: '🪹', colorClass: 'color-yellow' },
        { id: 'ph_o', value: 'O', name: 'Ah!', objectEmoji: '🦉', colorClass: 'color-blue' },
        { id: 'ph_p', value: 'P', name: 'Puh!', objectEmoji: '🐷', colorClass: 'color-pink' },
        { id: 'ph_q', value: 'Q', name: 'Kwuh!', objectEmoji: '👑', colorClass: 'color-yellow' },
        { id: 'ph_r', value: 'R', name: 'Rrr!', objectEmoji: '🐰', colorClass: 'color-white' },
        { id: 'ph_s', value: 'S', name: 'Sss!', objectEmoji: '☀️', colorClass: 'color-blue' },
        { id: 'ph_t', value: 'T', name: 'Tuh!', objectEmoji: '🐯', colorClass: 'color-orange' },
        { id: 'ph_u', value: 'U', name: 'Uh!', objectEmoji: '☂️', colorClass: 'color-purple' },
        { id: 'ph_v', value: 'V', name: 'Vvv!', objectEmoji: '🚐', colorClass: 'color-blue' },
        { id: 'ph_w', value: 'W', name: 'Wuh!', objectEmoji: '🍉', colorClass: 'color-green' },
        { id: 'ph_x', value: 'X', name: 'Ks!', objectEmoji: '🎹', colorClass: 'color-pink' },
        { id: 'ph_y', value: 'Y', name: 'Yuh!', objectEmoji: '🪀', colorClass: 'color-green' },
        { id: 'ph_z', value: 'Z', name: 'Zzz!', objectEmoji: '🦓', colorClass: 'color-white' }
    ],
    coloringAnimals: [
        { id: 'col_lion', name: 'Lion', image: 'assets/coloring/lion.png' },
        { id: 'col_elephant', name: 'Elephant', image: 'assets/coloring/elephant.jpg' },
        { id: 'col_goat', name: 'Goat', image: 'assets/coloring/goat.jpg' },
        { id: 'col_dog', name: 'Dog', image: 'assets/coloring/dog.png' },
        { id: 'col_cat', name: 'Cat', image: 'assets/coloring/cat.png' },
        { id: 'col_fish', name: 'Fish', image: 'assets/coloring/fish.png' },
        { id: 'col_bird', name: 'Bird', image: 'assets/coloring/bird.png' },
        { id: 'col_cow', name: 'Cow', image: 'assets/coloring/cow.png' },
        { id: 'col_horse', name: 'Horse', image: 'assets/coloring/horse.png' },
        { id: 'col_monkey', name: 'Monkey', image: 'assets/coloring/monkey.png' },
        { id: 'col_giraffe', name: 'Giraffe', image: 'assets/coloring/giraffe.jpg' },
        { id: 'col_zebra', name: 'Zebra', image: 'assets/coloring/zebra.jpg' },
        { id: 'col_tiger', name: 'Tiger', image: 'assets/coloring/tiger.jpg' },
        { id: 'col_rabbit', name: 'Rabbit', image: 'assets/coloring/rabbit.jpg' },
        { id: 'col_pig', name: 'Pig', image: 'assets/coloring/pig.jpg' },
        { id: 'col_sheep', name: 'Sheep', image: 'assets/coloring/sheep.jpg' },
        { id: 'col_duck', name: 'Duck', image: 'assets/coloring/duck.jpg' },
        { id: 'col_frog', name: 'Frog', image: 'assets/coloring/frog.jpg' },
        { id: 'col_turtle', name: 'Turtle', image: 'assets/coloring/turtle.jpg' },
        { id: 'col_butterfly', name: 'Butterfly', image: 'assets/coloring/butterfly.jpg' },
        { id: 'col_bee', name: 'Bee', image: 'assets/coloring/bee.jpg' },
        { id: 'col_owl', name: 'Owl', image: 'assets/coloring/owl.jpg' },
        { id: 'col_penguin', name: 'Penguin', image: 'assets/coloring/penguin.jpg' },
        { id: 'col_panda', name: 'Panda', image: 'assets/coloring/panda.jpg' },
        { id: 'col_koala', name: 'Koala', image: 'assets/coloring/koala.jpg' }
    ]
};

// Helper to generate a number set dynamically
function generateNumberRange(min, max) {
    const range = [];
    const colors = ['color-red', 'color-blue', 'color-green', 'color-yellow', 'color-orange', 'color-purple'];
    const categories = Object.keys(countingObjects);
    
    for (let i = min; i <= max; i++) {
        const cat = categories[Math.floor(Math.random() * categories.length)];
        const objPool = countingObjects[cat];
        const obj = objPool[Math.floor(Math.random() * objPool.length)];
        
        range.push({
            id: `num_${i}`,
            value: i,
            name: i.toString(),
            colorClass: colors[i % colors.length],
            objectCategory: cat,
            objectName: obj.name,
            objectEmoji: obj.emoji,
            objectSound: obj.sound
        });
    }
    return range;
}

// Encouraging phrases
const rewards = ["Great job!", "Awesome!", "You did it!", "Amazing!", "Yay!"];
const encouragements = ["Try again!", "Oops! Let's find ", "You can do it! Find "];
