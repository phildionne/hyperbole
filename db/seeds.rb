readability = Readability.new(ENV['READABILITY_API_KEY'])
@current_user = User.first

articles = [
  ['https://medium.com/really-big-ideas-we-should-try/32eeaacc207a', 'rand'],
  ['http://web.mit.edu/newsoffice/2012/lead-proton-collisions-at-large-hadron-collider-yield-surprising-results-1127.html', 'rand'],
  ['http://kylerush.net/blog/meet-the-obama-campaigns-250-million-fundraising-platform/', 'rand'],
  ['http://www.hashicorp.com/blog/announcing-hashicorp.html', 'rand'],
  ['http://blog.alexmaccaw.com/the-next-web', 'rand'],
  ['http://markdotto.com/2012/11/29/the-perfect-sandwich/', 'rand'],
  ['http://blog.cloudflare.com/how-syria-turned-off-the-internet', 'rand'],
  ['http://www.wired.com/wiredscience/2012/11/recent-human-evolution-2/', 'rand'],
  ['http://www.listsofnote.com/2012/04/einsteins-demands.html', 'rand'],
  ['http://www.wired.com/wiredenterprise/2012/11/google-spanner-time/', 'rand'],
  ['http://500hats.com/what-hasnt-changed', 'rand'],
  ['http://blog.yonas.io/post/36534887793/b2d-is-sexier', 'rand'],
  ['http://cdixon.org/2012/10/18/the-economic-logic-behind-tech-and-talent-acquisitions', 'rand'],
  ['http://www.nytimes.com/2012/11/24/science/scientists-see-advances-in-deep-learning-a-part-of-artificial-intelligence.html?_r=0', 'rand'],
  ['http://www.gq.com/news-politics/newsmakers/201205/chris-chaney-hacker-nude-photos-scarlett-johansson', 'rand'],
  ['http://cdixon.org/2012/11/23/some-problems-are-so-hard-they-need-to-be-solved-piece-by-piece/', 'rand'],
  ['https://medium.com/open-source/7d4fa461a9', 'rand'],
  ['http://blog.steveklabnik.com/posts/2012-11-22-introducing-the-rails-api-project', 'rand'],
  ['http://arstechnica.com/tech-policy/2012/11/us-patent-chief-to-software-patent-critics-give-it-a-rest-already/', 'rand'],
  ['http://www.bothsidesofthetable.com/2012/11/13/if-it-didnt-happen-on-twitter-it-didnt-really-happen-heres-why', 'rand'],
  ['http://www.wired.com/magazine/2011/01/ff_lottery/all/1', 'rand'],
  ['http://pandodaily.com/2012/11/20/the-last-day/', 'rand'],
  ['http://37signals.com/svn/posts/3321-behind-the-scenes-twitter-part-3-a-win-for-simple', 'rand'],
  ['http://37signals.com/svn/posts/3325-regression-and-extraction', 'rand'],
  ['http://37signals.com/svn/posts/3319-behind-the-scenes-twitter-part-2-lessons-from-email', 'rand'],
  ['http://www.nytimes.com/2012/11/18/opinion/sunday/the-quiet-ones.html', 'rand'],
  ['http://paulgraham.com/startupideas.html', 'rand'],
  ['http://500hats.typepad.com/500blogs/2009/01/great-entrepreneurs-are-passionate-about-their-customers-products-not-about-being-great-entrepreneur.html', 'rand'],
  ['http://37signals.com/svn/posts/3331-seeing-the-world-on-the-clock', 'rand'],
  ['http://37signals.com/svn/posts/3329-the-british-are-coming', 'rand'],
  ['http://www.bothsidesofthetable.com/2012/11/18/entrepreneurshit-the-blog-post-on-what-its-really-like/', 'rand'],
  ['http://blog.davidkatz.me/post/36010138674/entrepreneurshit-please', 'rand'],
  ['http://viniciusvacanti.com/2012/11/19/the-depressing-day-after-you-get-techcrunched/', 'rand'],
  ['https://training.kalzumeus.com/newsletters/archive/consulting_1', 'rand'],
  ['http://37signals.com/svn/posts/3330-better-remote-collaboration-will-make-protectionism-harder', 'rand'],
  ['http://37signals.com/svn/posts/3328-twitters-descent-into-the-extractive', 'rand'],
  ['http://daltoncaldwell.com/twitter-is-pivoting', 'rand'],
  ['http://blog.josephwilk.net/ruby/recurrent-neural-networks-in-ruby.html', 'rand'],
  ['http://numeratechoir.com/how-angellist-quantitatively-changes-the-investing-game/', 'rand'],
  ['http://37signals.com/svn/posts/3297-a-case-for-clarity-in-feedback', 'rand'],
  ['http://www.bbc.co.uk/news/magazine-20243692', 'rand'],
  ['http://allthingsd.com/20121115/google-launches-ingress-a-worldwide-mobile-alternate-reality-game/', 'rand'],
  ['http://ninjasandrobots.com/facebook-pages-nest-thermostat', 'rand'],
  ['http://cdixon.org/2009/08/25/six-strategies-for-overcoming-chicken-and-egg-problems/', 'rand'],
  ['http://daltoncaldwell.com/understanding-likegate', 'rand'],
  ['http://gigaom.com/2012/12/03/marc-andreessen-not-every-startup-should-be-a-lean-startup-or-embrace-the-pivot', 'today'],
  ['http://craigmod.com/journal/subcompact_publishing/', 'today'],
  ['http://joel.is/post/37111202497/feeling-like-a-fraud-while-doing-startups', 'today'],
  ['http://daringfireball.net/2012/12/why_the_daily_failed', 'today'],
  ['http://readwrite.com/2012/12/03/lets-all-shed-tears-for-the-crappy-startups-that-cant-raise-any-more-money', 'today'],
  ['http://richardminerich.com/2012/12/my-education-in-machine-learning-via-cousera/', 'today']
]


articles.each do |art|

    begin
      readability_hash = readability.parse(art[0])

      ap "Processing #{readability_hash[:url]}"

      rescue *Readability::READABILITY_API_ERRORS => e
      ap e.inspect
      next
    end # begin

    article = Article.new
    article.user = @current_user
    article.uri = readability_hash[:url]
    article.title = readability_hash[:title]
    article.save

    if art[1] == 'rand'
      article.update_attribute(:created_at, Time.now - (10000000*rand))
    elsif art[1] == 'today'
      article.update_attribute(:created_at, Time.now)
    end

end # articles.each
