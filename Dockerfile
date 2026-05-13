# We use Java 8 which is a requirement for the original ScadaBR
FROM tomcat:8.5-jdk8-openjdk

WORKDIR /usr/local/tomcat/webapps

# 1. Remove standard apps
RUN rm -rf ROOT/ examples/ docs/

# 2. Copy your local war file in to the container
COPY ScadaBR.war .

# 3. Unpack to be able to change the configuration (sed commands)
RUN mkdir -p ScadaBR && unzip ScadaBR.war -d ScadaBR && rm ScadaBR.war

# 4. Change database connection to the MySQL container (scadadb at 10.0.50.15)
RUN sed -i 's/db.type=.*/db.type=mysql/' ScadaBR/WEB-INF/classes/env.properties && \
    sed -i 's|db.url=.*|db.url=jdbc:mysql://10.0.50.15:3306/scadabr|' ScadaBR/WEB-INF/classes/env.properties && \
    sed -i 's/db.username=.*/db.username=root/' ScadaBR/WEB-INF/classes/env.properties && \
    sed -i 's/db.password=.*/db.password=root/' ScadaBR/WEB-INF/classes/env.properties

# 5. Global fix for sortSelect on all relevant pages
RUN find ScadaBR -name "*.jsp" -exec sed -i 's|</head>|<script type="text/javascript">var sortSelect = function(sel, sortAsc) { var options = sel.options; var arr = []; for (var i = 0; i < options.length; i++) { arr.push({ text: options[i].text, value: options[i].value, selected: options[i].selected }); } arr.sort(function(a, b) { if (sortAsc) return a.text.localeCompare(b.text); return b.text.localeCompare(a.text); }); for (var i = 0; i < options.length; i++) { options[i].text = arr[i].text; options[i].value = arr[i].value; options[i].selected = arr[i].selected; } };</script></head>|' {} +

EXPOSE 8080
CMD ["catalina.sh", "run"]
