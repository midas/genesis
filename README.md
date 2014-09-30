### NOTE: This project is dead in favor of the [phil_columns](https://github.com/midas/phil_columns) project

# genesis

A data seeding solution for Ruby on Rails providing seeding facilities far more advanced than the current built 
in Ruby on Rails solution.


## HISTORY

This gem is a continuation of my db-seed project (http://github.com/midas/db-seed).

I cannot claim the idea for this plugin or all of the implementation to be entirely mine. I have basically taken the 
db-populate plugin by Josh Knowles and added some functionality outlined at RailsSpikes and then extended it with my 
own ideas.  That said, genesis does work more like Rails active record migrations than db-populate or the other db 
seeding tools currently available.


## FEATURES

* Prepare seeding generator
* Genesis seed file generator similar to the Rails migration generator
* Seed version task
* Seeding task
* Database mulligan task (runs db:migrate:reset and then seeds)
* Only run seeds from the all and the current environment folder the task is being 
  executed within (ie. all seeds from db/seeds and db/seeds/production when rake 
  db:genesis RAILS_ENV=production)


## COMPATABILITY

* Ruby 1.8
* Rails 3
* Rails 2 (no generators)


## REQUIREMENTS

* ActiveRecord >= 2.0


## INSTALL

    gem install genesis

Run the prepare seeding generator to create a lib/tasks/genesis.rake file:

    rails generate genesis:install

Or to specify which environments to create:

    rails generate genesis:install [development,staging,production]

Generate a seed file:

    rails generate genesis:seed create_users

This will generate a seed file for you in the db/seeds directory.

Generate a seed file in a specific environment folder:

    rails generate genesis:seed create_users production

This will generate a seed file for you in the db/seeds/production directory.

Finally, simply populate the self.up and self.down methods of the generated seed file.  The seed is a normal Ruby class.

For convenience, ActiveRecord is extended with the following methods:

### create_or_update_by_all

    user = User.create_or_update_by_all( :name => 'John Smith', :number => '012345', :status => 'active' )

Will try to find a user with the name 'John Smith' and number '012345'.  If found, will return, otherwise will create 
the user and return it.

### create_or_update_by_some

    user = User.create_or_update_by_some( :find_by => { :name => 'John Smith', :status => 'active' }, :number => '012345' )

Will try to find a user with the name 'John Smith' and a status of 'active.'  If found will update with other attributes 
and save returning it.  If not found, will create the user with all the attributes (name, status and number) and return it.

### create_or_update_by_{attribute}

    user = User.find_or_update_by_name( :name => 'John Smith', :number => '012345', :status => 'active' )

Will try to find a user with the name 'John Smith.'  If found will update with other attributes and save returning it.  If 
not found, will create the user with all the attributes (name and number) and return it.


## LICENSE

Copyright (c) 2009 C. Jason Harrelson (midas)

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
