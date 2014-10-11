#!/usr/bin/python
import os.path,sys,pprint
from glob import glob

PROJECT_PATH = os.path.dirname(os.path.realpath(__file__))
PROJECT_PYTHON_PATHS = [
    os.path.join(PROJECT_PATH, "..", "python-packages"),
    PROJECT_PATH,
    os.path.join(PROJECT_PATH, ".."),
]
sys.path = PROJECT_PYTHON_PATHS + sys.path


from django.core.management import setup_environ
from main import settings
import main.topic_tools as T

setup_environ(settings)


def fn_from_videopath(path):
  if path.startswith("/"):
    path = path[1:]
  if path.endswith("/"):
    path = path[:-1]	
  path = path.replace("/",":")
  return path

videos = T.get_topic_videos(topic_id=T.get_topic_tree()['id'])
#pprint.pprint(videos[0])
for v in videos:
  files = glob(os.path.join("..","content",v['youtube_id'])+"*")
  for f in files:
    base,ext = os.path.splitext(f)
    linkdst = os.path.basename(f)
    linkname = os.path.join("..","content",fn_from_videopath(v['path'])+ext)
    #print "ln -s %s %s" % (linkdst,linkname)
    if os.path.islink(linkname):
      os.unlink(linkname)
    if os.path.exists(linkname):
      sys.stderr.write("WARNING: Refusing to overwrite non-symlink: %s\n" % linkname)
    os.symlink(linkdst,linkname)

