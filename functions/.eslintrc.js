module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    // Membatasi panjang baris maksimum menjadi 80 karakter
    "max-len": ["error", {code: 80}],

    // Mencegah penggunaan spasi ganda
    "no-multi-spaces": ["error"],

    // Mengatur penggunaan tanda kutip menjadi double quotes
    "quotes": ["error", "double", {allowTemplateLiterals: true}],

    // Lebih menyukai penggunaan arrow function untuk callback
    "prefer-arrow-callback": "error",

    // Mencegah penggunaan variabel global tertentu seperti name, length
    "no-restricted-globals": ["error", "name", "length"],

    // Memastikan ada koma setelah elemen terakhir di objek/array multiline
    "comma-dangle": ["error", "always-multiline"],
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
