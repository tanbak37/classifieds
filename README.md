# Classifieds

File Encryption Manager.

## Description

Classifieds manages the encryption of files in the repository.

It is possible to securely encrypted using OpenSSL and also possible to manage them easily.

## Installation

```
$ gem install classifieds
```

## Usage

Initialize classifieds.

```
$ classifieds init
```

Encrypt files which were described in .classifieds.

```
$ classifieds encrypt
```

Decrypt files which were described in .classifieds.

```
$ classifieds decrypt
```

Show a status of the encryption of this repository.

```
$ classifieds status
```

## Example

In your repository:

```
├── bar
│   ├── bar1
│   └── bar2
├── foo
├── fuga
│   ├── fuga1
│   └── fuga2
└── hoge
    ├── hoge1.rb
    └── hoge2
```

First, initialize classifieds.

```
$ classifieds init
.classifieds was created

$ ls -a
.classifieds  bar/  foo  fuga/  hoge/
```

Write files as relative path from `.classifieds` which you want to encrypt in `.classifieds`.

```
$ vim .classifieds
bar/*
!bar/bar1
foo
fuga
*/*.rb
```

Show the status.

```
$ classifieds status
Unencrypted:
        /path/to/foo
        /path/to/bar/bar2
        /path/to/hoge/hoge1.rb
        /path/to/fuga/fuga1
        /path/to/fuga/fuga2
```

Encrypt files.

```
$ classifieds encrypt
Password:
Retype password:
Encrypted:
        /path/to/foo
        /path/to/bar/bar2
        /path/to/hoge/hoge1.rb
        /path/to/fuga/fuga1
        /path/to/fuga/fuga2
```

Check the status.

```
$ classifieds status
Encrypted:
        /path/to/foo
        /path/to/bar/bar2
        /path/to/hoge/hoge1.rb
        /path/to/fuga/fuga1
        /path/to/fuga/fuga2

$ cat foo
65c0ec273963aacc69af593b03d1710ff90f75da¢É¸¤°öaDJ³
```

Decrypt files.

```
$ classifieds decrypt
Password:
Decrypted:
        /path/to/foo
        /path/to/bar/bar2
        /path/to/hoge/hoge1.rb
        /path/to/fuga/fuga1
        /path/to/fuga/fuga2
```

Check the status.

```
$ classifieds status
Unencrypted:
        /path/to/foo
        /path/to/bar/bar2
        /path/to/hoge/hoge1.rb
        /path/to/fuga/fuga1
        /path/to/fuga/fuga2

$ cat foo
foo
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/kaihar4/classifieds/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
