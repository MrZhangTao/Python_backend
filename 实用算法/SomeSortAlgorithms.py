# Some sort algorithms
# 1.insert sort
# 图片理解:https://upload.wikimedia.org/wikipedia/commons/2/25/Insertion_sort_animation.gif
# 介绍：从左向右，把当前选定的值，插入到左侧有序数列中，找到插入位置后，(可能)需要移动位置.
def insert_sort(arr, reverse=False):
    '''insert_sort'''
    for i, v in enumerate(arr):
        curVal = v
        index = i - 1
        while index >= 0:
            if reverse:
                if arr[index] > curVal:
                    arr[index + 1] = arr[index]
                    arr[index] = curVal
                else:
                    break
            else:
                if arr[index] < curVal:
                    arr[index + 1] = arr[index]
                    arr[index] = curVal
                else:
                    break
            index -= 1
    
    # if reverse:
        # retArr.reverse()
    return arr

# 2.shell sort,which is a more effectical insert sort.
# 介绍：希尔排序是一种优化的插入排序，目的是为了减少比较次数
# 将数列以一定宽度等分(成2维数组)，然后以行为单位，进行常规的插入排序；
# 宽度逐渐减小直到为 0.
def shell_sort(arr):
    '''shell_sort'''
    count = len(arr)
    step = 2
    group = count // 2
    while group > 0:
        for unit in range(group):
            idxInG = unit + group
            while idxInG < count:
                val = arr[idxInG]
                indexInA = idxInG - group
                while indexInA >= 0:
                    if arr[indexInA] > val:
                        arr[indexInA + group] = arr[indexInA]
                        arr[indexInA] = val
                    indexInA -= group
                idxInG += group
        group //= step
    return arr
            
# 3.insert sort using binary search
# at first, we need understand what binary search is.
def binary_search(arr, l, r, t):
    '''binary_search'''
    if l > r:
        return -1
    m = l + (r - l) // 2
    if t == arr[m]:
        return m
    elif t > arr[m]:
        return binary_search(arr, m + 1, r, t)
    else:
        return binary_search(arr, l, m - 1, t)

# and then:
def binary_insert(arr, l, r, t):
    '''binary_insert'''
    m = l + (r - l) // 2
    if arr[m] >= t:
        if m - l > 1:
            return binary_insert(arr, l, m - 1, t)
        else:
            return m
    else:
        if r - m > 1:
            return binary_insert(arr, m + 1, r, t)
        else:
            return r            

# at last:
def binary_sort(arr):
    '''binary sort'''
    count = len(arr)
    for i in range(1, count):
        val = arr[i]
        index = binary_insert(arr[:i], 0, i - 1, val)
        # swap
        tempIdx = i - 1
        while tempIdx > index:
            arr[tempIdx] = arr[tempIdx - 1]
            tempIdx -= 1
        arr[index] = val
    return arr

# 4.bubble sort
# 冒泡排序：普通版的：多轮次比较交换，将最值交换至一侧，最后无法比较则结束
#         优化：目的是减少不必要的比较交换
#         设置遍历上限或下限，同时使用标识来表示某轮次是否有产生交换，未交换，则排序结束
def bubble_sort(arr, optimized=True):
    '''bubble_sort'''
    if not optimized:
        for i in range(len(arr)):
            for j in range(i + 1, len(arr)):# after this round loop, arr[i] is the minimum val.
                if arr[i] > arr[j]:
                    arr[i], arr[j] = arr[j], arr[i]
    else:
        # set a changedFlag, which is the last visit pos
        count = len(arr)
        visitLimt = 0
        lastChangePos = 0
        while lastChangePos < count:
            visitLimt = lastChangePos
            lastChangePos = count
            i = count - 1
            while i > visitLimt:
                if arr[i] < arr[i - 1]:
                    arr[i], arr[i - 1] = arr[i - 1], arr[i]
                    lastChangePos = i
                i -= 1
    return arr


# 5.select sort
# 介绍：每一回合，把最值选出来并移至一侧
def select_sort(arr):
    '''select_sort'''
    for i in range(len(arr)):
        minI = i
        for j in range(i + 1, len(arr)):
            if arr[j] < arr[minI]:
                minI = j
        if minI != i:
            arr[minI], arr[i] = arr[i], arr[minI]
        
    return arr

# 6.quick sort
# intro:choose a value as a pivot in every round,
# the result is let all value in the left of pivot are smaller than pivot,
# all value in the right of pivot are bigger than pivot.
# 介绍：每一轮次，选择一个基值，该轮结束后，基值左侧的值全不大于基值，右侧的全不小于基值，然后"折半"继续
# 递归实现
def quick_sort(arr, left, right):
    '''quick_sort'''
    if left >= right:
        return
    curLeft, curRight = left, right
    curVal = arr[curLeft]
    while curLeft < curRight:
        while curLeft < curRight and arr[curRight] >= curVal:
            curRight -= 1
        arr[curLeft] = arr[curRight]
        while curLeft < curRight and arr[curLeft] <= curVal:
            curLeft += 1
        arr[curRight] = arr[curLeft]
    arr[curLeft] = curVal
    quick_sort(arr, left, curLeft - 1)
    quick_sort(arr, curLeft + 1, right)
    return arr

# 7.merge sort
# 介绍：将已有序的子序列合并，得到完全有序的序列(二路归并)
# picture::https://zh.wikipedia.org/wiki/%E5%BD%92%E5%B9%B6%E6%8E%92%E5%BA%8F#/media/File:Merge-sort-example-300px.gif
def merge(leftArr, rightArr):
    left, right = 0, 0
    retArr = []
    while left < len(leftArr) and right < len(rightArr):
        if leftArr[left] <= rightArr[right]:
            retArr.append(leftArr[left])
            left += 1
        else:
            retArr.append(rightArr[right])
            right += 1
    retArr += leftArr[left:]
    retArr += rightArr[right:]
    return retArr

def merge_sort(arr):
    '''merge_sort'''
    if len(arr) <= 1:
        return arr # suspend condition
    mid = len(arr) // 2
    leftArr = merge_sort(arr[:mid])
    rightArr = merge_sort(arr[mid:])
    return merge(leftArr, rightArr) # the final answer


def myPrint(arr, funcName, *args, **kw):
    '''formated print'''
    print("==> {}".format(funcName.__doc__))
    print("Before:", arr)
    print("After :", funcName(arr, *args, **kw))

if __name__ == "__main__":
    # insert sort test
    insert_sortExample = [4, 1, 3, 1, 2, 6, 6, 5, 7]
    # print(insert_sort(insert_sortExample))
    # print(insert_sort(insert_sortExample, True))
    myPrint(insert_sortExample, insert_sort, True)

    # shell sort test
    shell_sortExample = [1, 2, 3, 4, 1, 6, 9, 4, 10, 12, 8]
    myPrint(shell_sortExample, shell_sort)
    
    # binary search test
    orderArr = list(range(20))
    t = 0
    myPrint(orderArr, binary_search, 0, len(orderArr) - 1, t)

    # ==> binary sort test
    binary_sortExample = [4, 4, 2, 3, 10, 5, 1, 8, 11]
    myPrint(binary_sortExample, binary_sort)

    # ==> bubble sort test
    bubble_sortExample = [4, 3, 1, 1, 10, 5, 2, 8]
    myPrint(bubble_sortExample, bubble_sort)

    # ==> quick sort test
    quick_sortExample = [1, 2, 1, 4, 10, 9, 8 , 4, 5, 3]
    myPrint(quick_sortExample, quick_sort, 0, len(quick_sortExample) - 1)

    # ==> select sort test
    select_sortExample = [2, 3, 1, 4, 6, 9, 8, 5, 5]
    myPrint(select_sortExample, select_sort)

    # ==> merge sort test
    merge_sortExample = [2, 3, 1, 10, 8, 7, 11, 3, 5]
    myPrint(merge_sortExample, merge_sort)
