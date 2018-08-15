/* ERROR You are entering a duplicate orig_sys_line_ref for the same order

"Concurrent cannot be  Cancelled" for the parent request, Parent request
  status is 'Paused',  the child requests show as running
  
  
Line	Oracle E-Business Suite	
Family	Order Management
Area	Order Management
Product	497 - Oracle Order Management

DATA FIX provided did:
  1. delete the duplicate records in headers and lines iface all.
  2. update the error flag and request_id to NULL so that all the headers 
     will be picked by Order Import Concurrent request for Processing. */
	 

