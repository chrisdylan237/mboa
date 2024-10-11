FROM httpd

#updating the system
RUN apt update -y 

#variables
ARG port=80

#Container working directory
WORKDIR /usr/local/apache2/htdocs/
COPY inance .
RUN ls -l
#Preparing the folder++
 
#expose the container
EXPOSE ${port}