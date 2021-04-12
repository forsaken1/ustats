# User stats application

## Install

`bundle install`

IMPORTANT! Please, insert file `data_large.txt` for `data` directory.

## Run

### Profile & check with `data/data_medium.txt`

`ruby profile.rb`

### Large File

`ruby run.rb`

### Tests

`ruby test.rb`

## Results

### Machine

Macbook i7 2.2GHz 6 cores 32GB RAM

### Medium 100k lines

```
Time: 2.08879 seconds
Memory usage: 91.08 MB
```

### Large 3.3M lines

```
Time: 98.28416 seconds
Memory usage: 2565.56 MB
```

### Main optimisation

To use session mapping (an user id => an user's sessions) for `Ustats::Report#users_objects`
