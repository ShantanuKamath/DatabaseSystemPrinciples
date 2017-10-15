from xml.sax import make_parser
from handlers import DBLPHandler
import io

path_to_xml = "dblp.xml"

dblpHandler = DBLPHandler()
saxparser = make_parser()
saxparser.setContentHandler(dblpHandler)
saxparser.parse(io.open(path_to_xml))
