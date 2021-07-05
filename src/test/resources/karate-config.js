function() {
    var config = {};
    var env = karate.properties['karate.env'];

    if (typeof env == 'undefined') {
        env = 'UAT';
        karate.log('defaulting to env: ' + config.env);
    }
    var pathToAPIFolder = karate.properties['fw.apiObjectsFolder'];

    var endPoints = karate.read('classpath:' + pathToAPIFolder + '/resources/Resources.json');
    for(endPoint in endPoints) {
        config[endPoint] = endPoints[endPoint];
    }

    var baseURLs = karate.read('classpath:config/environments/' + env + '.json');
    for(baseURL in baseURLs) {
        config[baseURL] = baseURLs[baseURL];
    }

    return config;
}