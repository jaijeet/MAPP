
class UniqID_Generator:

    def __init__(self):
        self._count = -1

    def get_uniqID(self):
        self._count += 1
        return self._count

