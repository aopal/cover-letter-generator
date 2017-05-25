# cover-letter-generator

Ruby script to auto-generate cover letters and application packages for WaterlooWorks

Dependencies:
- ruby 2.3.x
- watir webdriver (`gem install watir`)
- combine_pdf (`gem install combine_pdf`)
  - Can be omitted if you only want a cover letter, though you will also need to comment out a few lines as well
- [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/) (add to your PATH)
- [wkhtmltopdf](https://wkhtmltopdf.org/) (add to your PATH)

You will also need to substitute your own mappings.json, resume-reference.pdf (if desired) and login credentials. Either use plaintext on your own machine if you're comfortable with that, or generate your own keypair with my rsa CLI tool [(node-RSA)](https://github.com/aopal/node-rsa) and generate your own `enc` file with your encrypted logon credentials.
