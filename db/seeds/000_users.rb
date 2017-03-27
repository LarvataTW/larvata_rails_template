puts 'Create Default Users.' if User.first_or_create!([
  {
    name: 'admin',
    email: 'admin@localhost',
    password: '12345678',
    password_confirmation: '12345678',
  },
  {
    name: 'user',
    email: 'user@localhost',
    password: '12345678',
    password_confirmation: '12345678',
  }
])
