// To parse this JSON data, do
//
//     final cimaMedicine = cimaMedicineFromJson(jsonString);

import 'dart:convert';

CimaMedicine cimaMedicineFromJson(String str) => CimaMedicine.fromJson(json.decode(str));

String cimaMedicineToJson(CimaMedicine data) => json.encode(data.toJson());

class CimaMedicine {
    String nregistro;
    String nombre;
    String pactivos;
    String labtitular;
    String labcomercializador;
    String cpresc;
    Estado estado;
    bool comerc;
    bool receta;
    bool generico;
    bool conduc;
    bool triangulo;
    bool huerfano;
    bool biosimilar;
    FormaFarmaceutica nosustituible;
    bool psum;
    bool notas;
    bool materialesInf;
    bool ema;
    List<Doc> docs;
    List<Foto> fotos;
    List<Atc> atcs;
    List<Excipiente> principiosActivos;
    List<Excipiente> excipientes;
    List<FormaFarmaceutica> viasAdministracion;
    List<Presentacione> presentaciones;
    FormaFarmaceutica formaFarmaceutica;
    FormaFarmaceutica formaFarmaceuticaSimplificada;
    FormaFarmaceutica vtm;
    String dosis;

    CimaMedicine({
        required this.nregistro,
        required this.nombre,
        required this.pactivos,
        required this.labtitular,
        required this.labcomercializador,
        required this.cpresc,
        required this.estado,
        required this.comerc,
        required this.receta,
        required this.generico,
        required this.conduc,
        required this.triangulo,
        required this.huerfano,
        required this.biosimilar,
        required this.nosustituible,
        required this.psum,
        required this.notas,
        required this.materialesInf,
        required this.ema,
        required this.docs,
        required this.fotos,
        required this.atcs,
        required this.principiosActivos,
        required this.excipientes,
        required this.viasAdministracion,
        required this.presentaciones,
        required this.formaFarmaceutica,
        required this.formaFarmaceuticaSimplificada,
        required this.vtm,
        required this.dosis,
    });

    factory CimaMedicine.fromJson(Map<String, dynamic> json) => CimaMedicine(
        nregistro: json["nregistro"],
        nombre: json["nombre"],
        pactivos: json["pactivos"],
        labtitular: json["labtitular"],
        labcomercializador: json["labcomercializador"],
        cpresc: json["cpresc"],
        estado: Estado.fromJson(json["estado"]),
        comerc: json["comerc"],
        receta: json["receta"],
        generico: json["generico"],
        conduc: json["conduc"],
        triangulo: json["triangulo"],
        huerfano: json["huerfano"],
        biosimilar: json["biosimilar"],
        nosustituible: FormaFarmaceutica.fromJson(json["nosustituible"]),
        psum: json["psum"],
        notas: json["notas"],
        materialesInf: json["materialesInf"],
        ema: json["ema"],
        docs: json["docs"] != null 
            ? List<Doc>.from(json["docs"].map((x) => Doc.fromJson(x))) 
            : [],
        fotos: json["fotos"] != null 
            ? List<Foto>.from(json["fotos"].map((x) => Foto.fromJson(x))) 
            : [],
        atcs: json["atcs"] != null 
            ? List<Atc>.from(json["atcs"].map((x) => Atc.fromJson(x))) 
            : [],
        principiosActivos: json["principiosActivos"] != null 
            ? List<Excipiente>.from(json["principiosActivos"].map((x) => Excipiente.fromJson(x))) 
            : [],
        excipientes: json["excipientes"] != null 
            ? List<Excipiente>.from(json["excipientes"].map((x) => Excipiente.fromJson(x))) 
            : [],
        viasAdministracion: json["viasAdministracion"] != null 
            ? List<FormaFarmaceutica>.from(json["viasAdministracion"].map((x) => FormaFarmaceutica.fromJson(x))) 
            : [],
        presentaciones: json["presentaciones"] != null 
            ? List<Presentacione>.from(json["presentaciones"].map((x) => Presentacione.fromJson(x))) 
            : [],
        formaFarmaceutica: FormaFarmaceutica.fromJson(json["formaFarmaceutica"]),
        formaFarmaceuticaSimplificada: FormaFarmaceutica.fromJson(json["formaFarmaceuticaSimplificada"]),
        vtm: FormaFarmaceutica.fromJson(json["vtm"]),
        dosis: json["dosis"],
    );

    Map<String, dynamic> toJson() => {
        "nregistro": nregistro,
        "nombre": nombre,
        "pactivos": pactivos,
        "labtitular": labtitular,
        "labcomercializador": labcomercializador,
        "cpresc": cpresc,
        "estado": estado.toJson(),
        "comerc": comerc,
        "receta": receta,
        "generico": generico,
        "conduc": conduc,
        "triangulo": triangulo,
        "huerfano": huerfano,
        "biosimilar": biosimilar,
        "nosustituible": nosustituible.toJson(),
        "psum": psum,
        "notas": notas,
        "materialesInf": materialesInf,
        "ema": ema,
        "docs": List<dynamic>.from(docs.map((x) => x.toJson())),
        "fotos": List<dynamic>.from(fotos.map((x) => x.toJson())),
        "atcs": List<dynamic>.from(atcs.map((x) => x.toJson())),
        "principiosActivos": List<dynamic>.from(principiosActivos.map((x) => x.toJson())),
        "excipientes": List<dynamic>.from(excipientes.map((x) => x.toJson())),
        "viasAdministracion": List<dynamic>.from(viasAdministracion.map((x) => x.toJson())),
        "presentaciones": List<dynamic>.from(presentaciones.map((x) => x.toJson())),
        "formaFarmaceutica": formaFarmaceutica.toJson(),
        "formaFarmaceuticaSimplificada": formaFarmaceuticaSimplificada.toJson(),
        "vtm": vtm.toJson(),
        "dosis": dosis,
    };
}

class Atc {
    String codigo;
    String nombre;
    int nivel;

    Atc({
        required this.codigo,
        required this.nombre,
        required this.nivel,
    });

    factory Atc.fromJson(Map<String, dynamic> json) => Atc(
        codigo: json["codigo"],
        nombre: json["nombre"],
        nivel: json["nivel"],
    );

    Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "nombre": nombre,
        "nivel": nivel,
    };
}

class Doc {
    int tipo;
    String url;
    String? urlHtml;
    bool secc;
    int fecha;

    Doc({
        required this.tipo,
        required this.url,
        this.urlHtml,
        required this.secc,
        required this.fecha,
    });

    factory Doc.fromJson(Map<String, dynamic> json) => Doc(
        tipo: json["tipo"],
        url: json["url"],
        urlHtml: json["urlHtml"],
        secc: json["secc"],
        fecha: json["fecha"],
    );

    Map<String, dynamic> toJson() => {
        "tipo": tipo,
        "url": url,
        "urlHtml": urlHtml,
        "secc": secc,
        "fecha": fecha,
    };
}

class Estado {
    int aut;

    Estado({
        required this.aut,
    });

    factory Estado.fromJson(Map<String, dynamic> json) => Estado(
        aut: json["aut"],
    );

    Map<String, dynamic> toJson() => {
        "aut": aut,
    };
}

class Excipiente {
    int id;
    String nombre;
    String cantidad;
    String unidad;
    int orden;
    String? codigo;

    Excipiente({
        required this.id,
        required this.nombre,
        required this.cantidad,
        required this.unidad,
        required this.orden,
        this.codigo,
    });

    factory Excipiente.fromJson(Map<String, dynamic> json) => Excipiente(
        id: json["id"],
        nombre: json["nombre"],
        cantidad: json["cantidad"],
        unidad: json["unidad"],
        orden: json["orden"],
        codigo: json["codigo"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "cantidad": cantidad,
        "unidad": unidad,
        "orden": orden,
        "codigo": codigo,
    };
}

class FormaFarmaceutica {
    int id;
    String nombre;

    FormaFarmaceutica({
        required this.id,
        required this.nombre,
    });

    factory FormaFarmaceutica.fromJson(Map<String, dynamic> json) => FormaFarmaceutica(
        id: json["id"],
        nombre: json["nombre"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
    };
}

class Foto {
    String tipo;
    String url;
    int fecha;

    Foto({
        required this.tipo,
        required this.url,
        required this.fecha,
    });

    factory Foto.fromJson(Map<String, dynamic> json) => Foto(
        tipo: json["tipo"],
        url: json["url"],
        fecha: json["fecha"],
    );

    Map<String, dynamic> toJson() => {
        "tipo": tipo,
        "url": url,
        "fecha": fecha,
    };
}

class Presentacione {
    String cn;
    String nombre;
    Estado estado;
    bool comerc;
    bool psum;

    Presentacione({
        required this.cn,
        required this.nombre,
        required this.estado,
        required this.comerc,
        required this.psum,
    });

    factory Presentacione.fromJson(Map<String, dynamic> json) => Presentacione(
        cn: json["cn"],
        nombre: json["nombre"],
        estado: Estado.fromJson(json["estado"]),
        comerc: json["comerc"],
        psum: json["psum"],
    );

    Map<String, dynamic> toJson() => {
        "cn": cn,
        "nombre": nombre,
        "estado": estado.toJson(),
        "comerc": comerc,
        "psum": psum,
    };
}
