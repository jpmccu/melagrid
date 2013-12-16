var redrugsApp = angular.module('redrugsApp', []);

redrugsApp.controller('ReDrugSCtrl', function ReDrugSCtrl($scope, $http) {
    $scope.elements = {
        nodes:[],
        edges:[]
    };
    $scope.nodeMap = {};
    $scope.edges = [];
    $scope.edgeMap = {};
    $scope.resources = {};
    $scope.searchTerms = "";
    $scope.searchTermURIs = {};
    $scope.getNode = function(uri) {
        var node = $scope.nodeMap[uri];
        if (!node) {
            node = $scope.nodeMap[uri] = {
                group: "nodes",
                data: {
                    id: uri,
                    types: {}
                }
            };
            $scope.elements.nodes.push(node);
        }
        return node;
    }
    $scope.layout = {
        name: 'grid',
        fit: true, // whether to fit the viewport to the graph
        padding: 50, // padding on fit
    }

    $scope.container = $('#results');
    $scope.container.cytoscape({
        style: cytoscape.stylesheet()
            .selector('node')
            .css({
                'content': 'data(label)',
                'text-valign': 'center',
                'color':'white',
                'background-color': 'data(color)',
                'shape': 'data(shape)',
                'text-outline-width': 2,
                'text-outline-color': 'data(color)'
            })
            .selector('edge')
            .css({
                'target-arrow-shape': 'triangle',
                'opacity':0.5,
                'width':"mapData(likelihood,0,2.5,0.5,10)",
                'target-arrow-shape': 'data(shape)'
            })
            .selector(':selected')
            .css({
                'background-color': 'black',
                'line-color': 'black',
                'target-arrow-color': 'black',
                'source-arrow-color': 'black',
                'opacity':1,
            })
            .selector('.faded')
            .css({
                'opacity': 0.25,
                'text-opacity': 0
            }),
        elements: [] ,
        ready: function(){
            $scope.cy = cy = this;
            // giddy up...
            console.log(cy.elements());
            cy.elements().unselectify();
            
            cy.on('tap', 'node', function(e){
                var node = e.cyTarget; 
                var neighborhood = node.neighborhood().add(node);
                
                cy.elements().addClass('faded');
                neighborhood.removeClass('faded');
            });
            
            cy.on('tap', function(e){
                if( e.cyTarget === cy ){
                    cy.elements().removeClass('faded');
                }
            });
	    $scope.container.cytoscapePanzoom();
            
	    $scope.container.cytoscapeNavigator();
            
            //$scope.cy.elements().one('select','node',function() {
            //    $scope.selected = $scope.getSelected();
            //    console.log($scope.selected);
            //});

            console.log($scope.cy);
        }
    });

    $("#searchBox").typeahead({
        minLength: 3,
        items: 10,
        updater: function(selection) {
            console.log(selection);
            $scope.searchTerms = selection;
            return selection;
        },
        source: function(query, process) {
            console.log(query);
            $http({method:'GET',url:"/api/typeahead?q="+encodeURIComponent(query)})
                .success(function(data) {
                    var keywords = data.keywords.map(function(d) {
                        var result = $.trim(d[0]);
                        //if (d[3]) result  = result + " ("+$.trim(d[3])+")";
                        //else if (d[2]) result = result + " ("+$.trim(d[2])+")";
                        $scope.searchTermURIs[result] = d[1];
                        return result;
                    })
                    process(keywords);
                })
                .error($scope.handleError);
        } 
    });
    $scope.handleError = function(data,status, headers, config) {
        $scope.error = true;
        $scope.loading = false;
    }
    $scope.getSelected = function() {
        if (!$scope.cy) return [];
        var selected = $scope.cy.$('node:selected');
        console.log(selected.nodes());
        var query = [];
        
        selected.nodes().each(function(i,d) {
            console.log(d);
            query.push(d.id())});
        console.log(query);
        return query;
    }
    $scope.addToGraph = function(query) {
        $scope.loading = true;
        console.log(query);
        query = [query].map(function(d) {
            return encodeURIComponent($scope.searchTermURIs[$.trim(d)])
        }).join(",")
        console.log(query);
        $http({method:'GET',url:"/api/addToGraph?uris="+query})
            .success($scope.appendToGraph)
            .error($scope.handleError);
    }
    $scope.getUpstream = function(query) {
        $scope.loading = true;
        console.log(query);
        query = query.map(encodeURIComponent).join(",")
        console.log(query);
        $http({method:'GET',url:"/api/getUpstream?uris="+query})
            .success($scope.appendToGraph)
            .error($scope.handleError);
    }
    $scope.getDownstream = function(query) {
        $scope.loading = true;
        console.log(query);
        query = query.map(encodeURIComponent).join(",")
        console.log(query);
        $http({method:'GET',url:"/api/getDownstream?uris="+query})
            .success($scope.appendToGraph)
            .error($scope.handleError);
    }
    $scope.addToGraphU2 = function(query) {
        console.log(query);
        query = query.split(",").map(function(d) {
            return encodeURIComponent($scope.searchTermURIs[$.trim(d)])
        }).join(",")
        console.log(query);
        $http({method:'GET',url:"/api/addToGraphU2?uris="+ query})
            .success($scope.appendToGraph)
            .error($scope.handleError);
    }

    $scope.edgeTypes = {
        "http://purl.obolibrary.org/obo/CHEBI_48705": "triangle",
        "http://purl.obolibrary.org/obo/MI_0190": "none",
        "http://purl.obolibrary.org/obo/CHEBI_23357": "triangle",
        "http://purl.obolibrary.org/obo/CHEBI_25212": "triangle",
        "http://purl.obolibrary.org/obo/CHEBI_35224": "none",
        "http://purl.obolibrary.org/obo/CHEBI_48706": "tee",
        "http://purl.org/obo/owl/GO#GO_0048018": "triangle",
        "http://www.berkeleybop.org/ontologies/owl/GO#GO_0030547":"tee",
        "http://purl.obolibrary.org/obo/MI_0915": "circle",
        "http://purl.obolibrary.org/obo/MI_0407": "none",
        "http://purl.obolibrary.org/obo/MI_0191": "circle",
        "http://purl.obolibrary.org/obo/MI_0914": "none",
        "http://purl.obolibrary.org/obo/MI_0217": "diamond",
        "http://purl.obolibrary.org/obo/MI_0403": "circle",
        "http://purl.obolibrary.org/obo/MI_0570": "square",
        "http://purl.obolibrary.org/obo/MI_0194": "square",
    }

    $scope.getShape = function (types) {
        if (types['http://semanticscience.org/resource/activator']) {
            return "triangle"
        } else if (types['http://semanticscience.org/resource/inhibitor']) {
            return "octogon"
        } else if (types['http://semanticscience.org/resource/protein']) {
            return "hexagon"
        } else {
            return "hexagon"
        }
    };
    $scope.getColor = function (types) {
        if (types['http://semanticscience.org/resource/activator']) {
            return "blue"
        } else if (types['http://semanticscience.org/resource/inhibitor']) {
            return "red"
        } else if (types['http://semanticscience.org/resource/protein']) {
            return "green"
        } else {
            return "green"
        }
    };
    $scope.appendToGraph = function(result) {
        console.log(result);
        $scope.edges = $scope.edges.concat(result.edges);
        var elements = [];
        result.edges.forEach(function(row) {
            if (!(row.probability > 0.9)) return;
            var source = $scope.getNode(row.participant);
            source.data.label = row.participantLabel;
            source.data.types[row.participantType] = true;
            source.data.shape = $scope.getShape(source.data.types);
            source.data.color = $scope.getColor(source.data.types);
            elements.push(source);
            var target = $scope.getNode(row.target);
            target.data.label = row.targetLabel;
            target.data.types[row.targetType] = true;
            target.data.shape = $scope.getShape(target.data.types);
            target.data.color = $scope.getColor(target.data.types);
            elements.push(target);
            var edge = {
                group: "edges",
                data: $().extend({}, row, {
                    id: row.interactions[0],
                    source:source.data.id,
                    target:target.data.id,
                    shape: $scope.edgeTypes[row.interactionType] ? $scope.edgeTypes[row.interactionType] : 'none'
                })
            };
            if (!$scope.edgeTypes[row.interactionType])
                console.log("Missing interaction tyoe:", row.interactionType);
            elements.push(edge);
        });
        $scope.cy.add(elements);
        $scope.cy.layout($scope.layout);
        console.log(elements);
        $scope.loading = false;
        $scope.loaded = result.edges.length;
        //$scope.updateDisplay();
    }
    $scope.result = $("#result");
    //$scope.svg = d3.select("#graph");
    //$scope.force = d3.layout.force();
    //.size([w, h]);
    //function updateSize() {
    //     width = $scope.result.width();
    //     height = $scope.result.height();
    //     $scope.svg.attr("width",width)
    //         .attr("height",height);
    //     //force.stop()
    //     $scope.force.size([width, height]);
    //     //    .start();
    // }
    // $(window).resize(updateSize);
    $scope.updateDisplay = function() {
        // $scope.force.stop()
        //     .charge(-1000)
        //     .size([$scope.result.width(), $scope.result.height()])
        //     .linkStrength(1)
        //     .linkDistance(30)
        //     .gravity(0.05)
        //     .nodes($scope.nodes)
        //     .links($scope.edges);
        // $scope.edgeSVG = $scope.makeEdgeSVG($scope.edges, $scope.svg);
        // $scope.nodeSVG = $scope.makeNodeSVG($scope.nodes, $scope.svg);
        // $scope.force.start();
    }

    $scope.makeEdgeSVG = function(edges, svg) {
        var result = svg.selectAll("line.edge")
            .data(edges).enter()
            .append("line")
            .attr("class","edge")
            .attr("stroke","black");
        return svg.selectAll("line.edge");
    }
    $scope.makeNodeSVG = function(nodes, svg) {
        var result = svg.selectAll("g.node")
            .data(nodes)
            .enter()
            .append("g")
            .attr("class","node")
        result.append("circle")
            .attr("r",20)
            .attr("stroke","black")
            .attr("fill","steelblue")
        result.append("text")
            .style("text-anchor","middle")
            .style("dominant-baseline","central")
            .text(function(d) {return d.label});
        return svg.selectAll("g.node");
    }
    // $scope.force.on("tick", function() {
    //     $scope.edgeSVG
    //         .attr("x1",function(d) {
    //             return d.source.x;
    //         })
    //         .attr("y1",function(d) {
    //             return d.source.y;
    //         })
    //         .attr("x2",function(d) {
    //             return d.target.x;
    //         })
    //         .attr("y2",function(d) {
    //             return d.target.y;
    //         })
    //     $scope.nodeSVG
    //         .attr("transform", function(d) {
    //             return "translate("+d.x+","+d.y+")";
    //         })
    // })
})