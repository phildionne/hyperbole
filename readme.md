# Hyperbole
Minimalist sinatra bookmarking app. Built for fun and to experiment with Sinatra.

## Getting started
1. `psql -c 'CREATE DATABASE hyperbole;'`
2. Set `DATABASE_URL` to something like `postgres://{user}:{password}@{host}:{port}/path`
3. Set `PORT`, `READABILITY_API_KEY`, `TWITTER_API_KEY` and `TWITTER_API_SECRET`

```
bundle install
bundle exec rake db:migrate
bundle exec foreman start
```

## Usage
1. Sign Up with your Twitter account
2. Bookmark interesting links by pasting them in the adress bar e.g. `localhost:9292/add/http://www.my-interesting-link.com`

## Author
[Philippe Dionne](http://www.phildionne.com)

## Copyright
Copyright (c) 2013 Philippe Dionne

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
