// Initialize the map in Buenos Aires
var map = L.map('map').setView([-34.6037, -58.3816], 12);

// Add a tile layer
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// Variables to store zones and markers
var zonas = [];
var results = L.layerGroup().addTo(map);


// Clear the map
function limpiarMapa() {
    puntosClusters.clearLayers();
    zonas.forEach(function (zona) {
        map.removeLayer(zona);
    });
    zonas = [];
    results.clearLayers(); // Clear markers from search
}

// Close any open popups
function cerrarPopup() {
    const existingPopup = document.getElementById("popupRubros");
    if (existingPopup) {
        existingPopup.remove();
    }
}


// Define un LayerGroup global para los puntos
var puntosClusters = L.layerGroup().addTo(map);

// Toggle between "By Rubro" and "By Zone"
function cambiarVisualizacion(opcion) {
    const rubroControl = document.getElementById("controls-rubro");
    const zonaControl = document.getElementById("controls-zona");
    const legend = document.getElementById("legend");

    if (opcion === "rubro") {
        rubroControl.style.display = "block"; // Muestra el selector de rubros
        zonaControl.style.display = "none";  // Oculta el selector de zonas
        legend.style.display = "block";     // Muestra la leyenda
        limpiarMapa();                       // Limpia el mapa
    } else if (opcion === "zona") {
        rubroControl.style.display = "none"; // Oculta el selector de rubros
        zonaControl.style.display = "block"; // Muestra el selector de zonas
        legend.style.display = "block";      // Muestra la leyenda
        limpiarMapa();                        // Limpia el mapa
    } else if (opcion === "cluster") {
        rubroControl.style.display = "none"; // Oculta el selector de rubros
        zonaControl.style.display = "none";  // Oculta el selector de zonas
        legend.style.display = "none";       // Oculta la leyenda
        limpiarMapa();                        // Limpia el mapa
        mostrarTodosLosPuntosDeClusters();           // Dibuja los puntos de los clústeres
    }
}

function mostrarTodosLosPuntosDeClusters() {
        // Limpia los puntos existentes antes de agregar nuevos
        limpiarMapa();
    
        fetch('/get_all_cluster_points')
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    alert("Error al cargar los clusters");
                    return;
                }
    
                // Agrega los puntos al LayerGroup
                data.points.forEach(point => {
                    L.circleMarker([point.latitude, point.longitude], {
                        color: obtenerColorPorCluster(point.cluster),
                        fillColor: point.color,
                        fillOpacity: 0.7,
                        radius: 1
                    }).addTo(puntosClusters); // Agrega al LayerGroup
                });
            })
            .catch(error => console.error("Error al cargar puntos de clúster:", error));
    }
    

// Función para definir colores por cluster (puedes personalizarla)
function obtenerColorPorCluster(cluster) {
    const colores = [
        '#FF5733', '#33FF57', '#3357FF', '#F3FF33', '#FF33F3', '#33FFF3', '#FFA500'
    ];
    return colores[cluster % colores.length];
}


function agregarLeyenda() {
    const leyenda = L.control({ position: "bottomright" });
    leyenda.onAdd = function (map) {
        const div = L.DomUtil.create("div", "info legend");
        div.innerHTML += "<i style='background: blue'></i> Puntos de Locales<br>";
        div.innerHTML += "<i style='background: red'></i> Otros datos<br>";
        return div;
    };
    leyenda.addTo(map);
}
agregarLeyenda();




function resaltarCluster(clusterId) {
    limpiarMapa(); // Limpia el mapa para resaltar solo el clúster seleccionado

    fetch(`/get_cluster_data?cluster_id=${clusterId}`)
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                console.error("Error al cargar datos del clúster:", data.error);
                alert(data.error);
                return;
            }

            // Dibujar el clúster seleccionado con mayor énfasis
            const polygon = L.polygon(data.cluster_polygon, {
                color: "orange",
                fillColor: "orange",
                fillOpacity: 0.6,
                weight: 3,
            }).addTo(map);

            zonas.push(polygon);
            map.fitBounds(polygon.getBounds());

            // Mostrar información en un popup
            const popupContent = `
                <h4>Clúster ${clusterId}</h4>
                <p><b>Cantidad de puntos:</b> ${data.num_points}</p>
                <p><b>Promedio de probabilidad:</b> ${data.avg_prob.toFixed(2)}</p>
                <p><b>Rubros predominantes:</b></p>
                <ul>
                    ${data.top_rubros.map(rubro => `<li>${rubro}</li>`).join('')}
                </ul>
            `;
            L.popup()
                .setLatLng(polygon.getBounds().getCenter())
                .setContent(popupContent)
                .openOn(map);
        })
        .catch(error => {
            console.error("Error al cargar clúster:", error);
            alert("Hubo un problema al cargar el clúster.");
        });
}


// Fetch suggestions for the autocomplete
function autocompletarDireccion() {
    const direccion = document.getElementById("direccion").value.trim();

    if (!direccion) {
        cerrarSugerencias();
        return;
    }

    const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(direccion)}&format=json&addressdetails=1&limit=5&countrycodes=ar&viewbox=-58.5317,-34.5261,-58.3358,-34.6755&bounded=1`;

    fetch(url)
        .then(response => response.json())
        .then(data => {
            cerrarSugerencias(); // Close previous suggestions
            const suggestions = document.createElement("ul");
            suggestions.id = "suggestions";
            suggestions.style.position = "absolute";
            suggestions.style.backgroundColor = "white";
            suggestions.style.border = "1px solid #ccc";
            suggestions.style.padding = "5px";
            suggestions.style.width = "100%";
            suggestions.style.zIndex = "1000";

            data.forEach(item => {
                const suggestion = document.createElement("li");
                suggestion.style.cursor = "pointer";
                suggestion.style.padding = "5px";
                suggestion.innerText = item.display_name;

                suggestion.addEventListener("click", () => {
                    document.getElementById("direccion").value = item.display_name;
                    buscarDireccionSeleccionada(item.lat, item.lon);
                    cerrarSugerencias();
                });

                suggestions.appendChild(suggestion);
            });

            document.getElementById("search-container").appendChild(suggestions);
        })
        .catch(error => console.error("Error al obtener sugerencias:", error));
}

// Close suggestions list
function cerrarSugerencias() {
    const suggestions = document.getElementById("suggestions");
    if (suggestions) {
        suggestions.remove();
    }
}

// Search and highlight the zone for the selected address
function buscarDireccionSeleccionada(lat, lon) {
    limpiarMapa(); // Clear the map
    cerrarPopup(); // Close any popups
    map.setView([lat, lon], 14); // Center map on the address

    const marcador = L.marker([lat, lon]).addTo(results);

    fetch(`/buscar_zona?lat=${lat}&lon=${lon}`)
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                alert(data.error);
            } else {
                console.log("Zona encontrada:", data.zona_id);
                mostrarRubrosPorZona(data.zona_id); // Highlight zone and show rubros
            }
        })
        .catch(error => console.error("Error al buscar la zona:", error));
}

// Close the popup
function mostrarPopupRubros(rubros, zonaBounds) {
    cerrarPopup(); // Cierra popups anteriores si existen.

    const popup = document.createElement("div");
    popup.id = "popupRubros";
    popup.style.position = "absolute";
    popup.style.top = "100px"; // Ajusta este valor según sea necesario para evitar superposición
    popup.style.right = "50px";
    popup.style.backgroundColor = "white";
    popup.style.border = "1px solid #ccc";
    popup.style.padding = "10px";
    popup.style.boxShadow = "0 4px 8px rgba(0,0,0,0.2)";
    popup.style.borderRadius = "5px";
    popup.style.zIndex = "1000"; // Asegúrate de que esté en el frente.

    // Título del popup
    const title = document.createElement("h4");
    title.innerText = "Rubros Ordenados por Probabilidad:";
    popup.appendChild(title);

    // Lista de rubros
    const list = document.createElement("ul");
    rubros.forEach((rubro) => {
        const listItem = document.createElement("li");
        listItem.innerText = `${rubro.nombre} - Probabilidad: ${rubro.probabilidad.toFixed(2)}`;
        list.appendChild(listItem);
    });
    popup.appendChild(list);

    // Botón de cierre
    const closeButton = document.createElement("button");
    closeButton.innerText = "Cerrar";
    closeButton.style.marginTop = "10px";
    closeButton.style.padding = "5px 10px";
    closeButton.style.backgroundColor = "red";
    closeButton.style.color = "white";
    closeButton.style.border = "none";
    closeButton.style.borderRadius = "3px";
    closeButton.style.cursor = "pointer";

    closeButton.addEventListener("click", () => {
        popup.remove();
    });
    popup.appendChild(closeButton);

    document.body.appendChild(popup);

    // Cierra el popup con la tecla Esc
    document.addEventListener("keydown", function escClose(event) {
        if (event.key === "Escape") {
            popup.remove();
            document.removeEventListener("keydown", escClose); // Limpia el evento
        }
    });
}

// Show popup with rubros
function mostrarRubrosPorZona() {
    const zona_id = document.getElementById("zona").value; // Captura el valor seleccionado
    console.log("Zona ID recibido:", zona_id);
    if (!zona_id || zona_id.trim() === "") {
        console.error("Zona ID no válido");
        alert("Por favor selecciona una zona válida.");
        return;
    }

    limpiarMapa();
    cerrarPopup();

    fetch(`/get_rubros_por_zona?zona_id=${zona_id}`)
        .then(response => response.json())
        .then(data => {
            console.log("Datos del backend para la zona:", data);
            if (data.error) {
                console.error("Error del backend:", data.error);
                alert(data.error);
                return;
            }

            if (data.zona && data.zona.polygon) {
                const processedPolygon = data.zona.polygon.map(coords => [coords[0], coords[1]]);
                console.log("Coordenadas procesadas para el polígono:", processedPolygon);

                const polygon = L.polygon(processedPolygon, {
                    color: "blue",
                    fillColor: "blue",
                    fillOpacity: 0.4,
                    weight: 2,
                }).addTo(map);

                zonas.push(polygon);
                console.log("Polígono agregado al mapa:", polygon);

                map.fitBounds(polygon.getBounds());
                mostrarPopupRubros(data.rubros);
            } else {
                console.error("Datos de la zona incompletos");
                alert("No se encontró información para esta zona.");
            }
        })
        .catch(error => {
            console.error("Error en el fetch:", error);
            alert("Hubo un problema al cargar los datos.");
        });
}


// Update the map with zones for the selected rubro
function actualizarMapa() {
    var rubroSeleccionado = document.getElementById("rubro").value;

    limpiarMapa(); // Clear previous zones and markers
    cerrarPopup(); // Close any open popups

    if (!rubroSeleccionado || rubroSeleccionado.trim() === "") {
        alert("Por favor selecciona un rubro.");
        return;
    }

    fetch(`/get_zonas?rubro=${encodeURIComponent(rubroSeleccionado)}`)
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                alert(data.error);
                return;
            }

            if (data.zonas && data.zonas.length > 0) {
                data.zonas.forEach(function (zona) {
                    // Create a polygon for the zone
                    var polygon = L.polygon(zona.polygon, {
                        color: zona.color,
                        fillColor: zona.color,
                        fillOpacity: 0.15,
                        weight: 1,
                    }).addTo(map);

                    // Add tooltip with probability
                    polygon.bindTooltip(`Probabilidad: ${zona.probabilidad_exito.toFixed(2)}`, {
                        permanent: false,
                        direction: "top",
                        offset: [0, -10],
                    });

                    // Highlight effect on mouseover
                    polygon.on('mouseover', function () {
                        polygon.setStyle({
                            weight: 3,
                            color: "#000",
                            fillOpacity: 0.6,
                        });
                    });

                    // Reset style on mouseout
                    polygon.on('mouseout', function () {
                        polygon.setStyle({
                            weight: 1,
                            color: zona.color,
                            fillOpacity: 0.15,
                        });
                    });

                    // Add the polygon to the zones array for cleanup
                    zonas.push(polygon);
                });

                // Adjust the map view to fit the zones
                var allBounds = data.zonas.map(z => L.polygon(z.polygon).getBounds());
                var combinedBounds = allBounds.reduce((bounds, b) => bounds.extend(b), L.latLngBounds());
                map.fitBounds(combinedBounds);
            } else {
                alert("No hay zonas para este rubro.");
            }
        })
        .catch(error => {
            console.error("Error al cargar zonas:", error);
            alert("Hubo un problema al cargar los datos. Por favor, inténtalo de nuevo.");
        });
}

function mostrarClusterSeleccionado() {
    const clusterId = document.getElementById("cluster").value;
    if (!clusterId) {
        alert("Por favor selecciona un clúster válido.");
        return;
    }

    limpiarMapa(); // Limpiar cualquier capa previa
    cerrarPopup(); // Cerrar popups abiertos

    fetch(`/get_cluster_data?cluster_id=${clusterId}`)
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                console.error("Error al cargar datos del clúster:", data.error);
                alert(data.error);
                return;
            }

            // Dibujar el polígono del clúster
            if (data.cluster_polygon) {
                const polygon = L.polygon(data.cluster_polygon, {
                    color: "orange",
                    fillColor: "orange",
                    fillOpacity: 0.4,
                    weight: 2,
                }).addTo(map);

                zonas.push(polygon); // Guardar referencia para limpieza
                map.fitBounds(polygon.getBounds()); // Ajustar vista al clúster
            }

            // Mostrar puntos del clúster
            if (data.cluster_points && data.cluster_points.length > 0) {
                data.cluster_points.forEach(point => {
                    L.circleMarker([point.lat, point.lng], {
                        radius: 1,
                        fillColor: "blue",
                        color: "#000",
                        weight: 1,
                        opacity: 1,
                        fillOpacity: 0.8,
                    }).addTo(results);
                });
            }
        })
        .catch(error => {
            console.error("Error al cargar clúster:", error);
            alert("Hubo un problema al cargar el clúster.");
        });
}
