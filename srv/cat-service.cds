using my.stage as stg from '../db/schema';

service CatalogService {

  entity Employees as projection on stg.Employees;

}
